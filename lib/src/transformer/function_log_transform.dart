import 'package:kernel/ast.dart';
// ignore: implementation_imports
import 'package:front_end/src/fasta/kernel/internal_ast.dart';

import 'store_utils.dart';


///aaa
class FunctionDebugTransform extends RecursiveVisitor<void> {

   String _methodName;
  @override
  void visitClass(Class node) {
    super.visitClass(node);
  }
  @override
  void visitProcedure(Procedure node) {

//    String procedureName = node.name.name;
//    if(procedureName == 'testAsync'){
//     ConstructorInvocation invocation =  node.annotations[0];
//      ConstructorInvocation constructorInvocation = invocation.arguments.named[0].value;
//      Reference reference = constructorInvocation.targetReference;
//      print('reference  = ${reference}');//可以通过注解中的构造获取到reference，for strategy
//    }
    final List<Expression> annotations = node.annotations;
    for(Expression ex in annotations){
      if(ex is ConstructorInvocation){
        final ConstructorInvocation invocation = ex;
        final Class cls = invocation?.targetReference?.node?.parent;
        final String clsName = cls.name;
        if(clsName == 'FunctionLog' && (node.kind == ProcedureKind.Method)){
          _methodName = node.name.name;
          final FunctionNode functionNode = node.function;
          final Block block = functionNode.body;
          ///取method参数，注意[String s]这种属于positionalParameters。构建参数输出
          final List<VariableDeclaration> parameters = <VariableDeclaration>[];
          parameters.addAll(functionNode.positionalParameters);
          parameters.addAll(functionNode.namedParameters);
          final PropertyGet p = PropertyGet(ConstructorInvocation(Stores.dateTimeNowConstructor,ArgumentsImpl(<Expression>[])),Name('millisecondsSinceEpoch'));
          startTimeDeclarationImpl = VariableDeclarationImpl('startTime',0,initializer: p,type:  InterfaceType.byReference(Stores.intReference,Nullability.legacy,<DartType>[]));
          if(parameters.isNotEmpty){
            ///方法含有参数
            buildPrintParametersStatement(parameters,block);
          }else{
            ///方法无参数
            ///当前时间的statement的定义
            block.statements.insert(0,startTimeDeclarationImpl);
          }

          if(node.function.returnType is VoidType){
            ///因为可能存在返回类型是VoidType，但是函数体内包含return关键字导致方法提前结束，所以需要调用addStatementForReturnStatment
            addStatementForReturnStatement(block.statements);
            addStatementForVoidType(block.statements);
          }else{ ///有返回值的方法，这里最好写 else if,可能是不同的DartType不同的处理方式
            addStatementForReturnStatement(block.statements);
          }
          break;
        }
      }
    }
  }
  VariableDeclarationImpl startTimeDeclarationImpl;

  ///为什么采用这种方法而不是直接替换方案的调用接口，重定向方法来实现，而且更简单：因为可能会出现各种与其他框架的冲突，在其他框架使用的时候，方法被替换后，无法找到正确的方法导致统计时间失败
  ///第一步要看这个方法是否具备返回值类型，也就是[FunctionNode]的[FunctionNode.returnType]是什么类型。具备返回值才进行return的搜索，终止条件就是搜索到[ReturnStatement]
  ///block.statements.length
  void addStatementForReturnStatement(List<Statement> statements ){
    final List<Statement> tem = List<Statement>.from(statements);
    for(Statement statement in tem){
      managerStatement(statement,statements: statements);
    }
  }

  ///处理Statement
  ///可能需要插入代码的地方是：
  ///1.普通Block含有的statement长度就是1,且自己就是一个Block
  ///2.IfStatement中
  ///
  void managerStatement(Statement statement,{List<Statement> statements}){
    List<Statement> temStatement;
    if(temStatement!=null){
      temStatement.clear();
    }
    temStatement = statements;
    switch(statement.runtimeType.toString()){
      case 'Block':
        final Block block = statement;
        if(block.statements.length > 1){
          addStatementForReturnStatement(block.statements);
        }else if(block.statements.length == 1){
          managerStatement(block.statements[0],statements: block.statements);
        }
        break;
      case 'ForStatement':
        final ForStatement forStatement = statement;
        managerStatement(forStatement.body);
        break;
      case 'IfStatement':
      ///对于[IfStatement]而言,其中的`otherwise`字段代表`else`或者`else if`的其他分支
        final IfStatement ifStatement = statement;
        managerStatement(ifStatement.then);
        if(ifStatement.otherwise!=null){
          ///代表它有else分支（当然这个else也可能会有下一个的else/else if）
          managerStatement(ifStatement.otherwise);
        }
        break;
      case 'ReturnStatementImpl':
      ///只能在这种情况下注入代码
        final ReturnStatement returnStatement = statement;
        ///如果它自己是调用的一个方法，需要改变方法的调用接收
        VariableDeclarationImpl declarationImpl ;
        if(returnStatement.expression!=null && returnStatement.expression is InvocationExpression){
          final MethodInvocation methodInvocation = returnStatement.expression;
          declarationImpl = VariableDeclarationImpl.forValue(methodInvocation);
          declarationImpl.name = 'temp';
          declarationImpl.type = const DynamicType();
          declarationImpl.parent = methodInvocation.parent;
          final int index = statements.indexOf(returnStatement);
          statements[index] = declarationImpl;
          final AsExpression asExpression = AsExpression(VariableGetImpl(declarationImpl,null,null,forNullGuardedAccess: false),const DynamicType());
          final ReturnStatementImpl returnStatementImpl = ReturnStatementImpl(false,asExpression);
          if(index == statements.length -1){
            temStatement.add(returnStatementImpl);
          }else{
            temStatement.insert(index+1, returnStatementImpl);
          }
        }
        _addStatementForReturnFuc(statements,statement,declarationImpl);
        break;
    }
    statements = temStatement;
  }

  ///增加插入代码。输出花费时间与函数返回值（针对有返回值的函数）
  void _addStatementForReturnFuc(List<Statement> statements,Statement statement,VariableDeclaration declaration){
    final VariableDeclarationImpl declarationImpl =  _buildTimeCostVariable();
    statements.insert(statements.length -1,declarationImpl);
    final ExpressionStatement expressionStatement = _buildCostTimePrintStatement(declarationImpl);
    statements.insert(statements.length -1,expressionStatement);
    ///输出原函数的返回值
    if(declaration!=null){
      final ArgumentsImpl argumentsImpl  = ArgumentsImpl(<Expression>[StringConcatenation(<Expression>[StringLiteral('return value = ')])]);
      final StringConcatenation stringConcatenation = argumentsImpl.positional[0];
      final VariableGetImpl argumentVariable =  VariableGetImpl(declaration,null,null,forNullGuardedAccess: false);
      stringConcatenation.expressions.add(argumentVariable);
      final StaticInvocation staticInvocation = StaticInvocation(Stores.printProcedure,argumentsImpl,isConst: false);
      final ExpressionStatement expressionStatement = ExpressionStatement(staticInvocation);
      statements.insert(statements.length -1,expressionStatement);
    }
  }

  ///返回值是void的情况[即使是写了返回值是dynamic，只要后面不带return+具体的值，都会是VoidType]
  ///还有一种情况是方法返回类型写的是dynamic，但是在方法体内写了return关键字，这时的ReturnType是dynamic
  ///返回值写的void，但是方法体内带有return，注意要在每个对应的return插入计算时间的值，不仅仅只在最后添加
  void addStatementForVoidType(List<Statement> statements) {
    final VariableDeclarationImpl declarationImpl =  _buildTimeCostVariable();
    statements.add(declarationImpl);
    final ExpressionStatement expressionStatement = _buildCostTimePrintStatement(declarationImpl);
    statements.add(expressionStatement);
  }

  ///构造参数的输出
  void buildPrintParametersStatement(List<VariableDeclaration> parameters,Block block) {
    final ArgumentsImpl argumentsImpl  = ArgumentsImpl(<Expression>[StringConcatenation(<Expression>[StringLiteral('--> $_methodName')])]);
    final StringConcatenation stringConcatenation = argumentsImpl.positional[0];
    stringConcatenation.expressions.add(StringLiteral('('));
    for(VariableDeclaration variableDeclaration in parameters){
      String variableType;

      if(variableDeclaration.type is InterfaceType){
        variableType = (variableDeclaration.type as InterfaceType).classNode.name;
      }else if(variableDeclaration.type is FunctionType){
        variableType = (variableDeclaration.type as FunctionType).typedef.name;
      }
      final String variableName = variableDeclaration.name;

      final StringLiteral parameterKeyStr = StringLiteral('$variableType $variableName = ');
      ///variableDeclaration取参数中的即可，不要重新构造，不然会造成[assert(index != null, "No index found for ${node.variable}");]这里的判断出错
      final VariableGetImpl argumentVariable =  VariableGetImpl(variableDeclaration,null,null,forNullGuardedAccess: false);
      stringConcatenation.expressions.add(parameterKeyStr);
      stringConcatenation.expressions.add(argumentVariable);
    }
    stringConcatenation.expressions.add(StringLiteral(')'));
    final StaticInvocation staticInvocation = StaticInvocation(Stores.printProcedure,argumentsImpl,isConst: false);
    ///参数输出的Statement
    final ExpressionStatement expressionStatement = ExpressionStatement(staticInvocation);
    block.statements.insert(0, expressionStatement);
    block.statements.insert(1,startTimeDeclarationImpl);
  }

  VariableDeclarationImpl _buildTimeCostVariable() {
    ///取上级 的属性声明
    final VariableGetImpl argumentVariable =  VariableGetImpl(startTimeDeclarationImpl,null,null,forNullGuardedAccess: false);
    final Arguments arguments = Arguments(<Expression>[argumentVariable]);
    final PropertyGet receiver = PropertyGet(ConstructorInvocation(Stores.dateTimeNowConstructor,ArgumentsImpl(<Expression>[])),Name('millisecondsSinceEpoch'));
    final MethodInvocation methodInvocation = MethodInvocation(receiver,Name('-'),arguments);
    return  VariableDeclarationImpl('result',0,initializer: methodInvocation,type:InterfaceType.byReference(Stores.intReference,Nullability.legacy,<DartType>[]));
  }

  ExpressionStatement _buildCostTimePrintStatement(VariableDeclarationImpl declarationImpl) {
    ///输出计算时间的差额
    final ArgumentsImpl argumentsImpl  = ArgumentsImpl(<Expression>[StringConcatenation(<Expression>[StringLiteral('<-- $_methodName cost time(耗时) = ')])]);
    final StringConcatenation stringConcatenation = argumentsImpl.positional[0];
    final VariableGetImpl costVariable =  VariableGetImpl(declarationImpl,null,null,forNullGuardedAccess: false);
    stringConcatenation.expressions.add(costVariable);
    stringConcatenation.expressions.add(StringLiteral('[ms]'));
    final StaticInvocation staticInvocation = StaticInvocation(Stores.printProcedure,argumentsImpl,isConst: false);
    return ExpressionStatement(staticInvocation);
  }


///对于每一个statement，根据其具体的实现类，一个个的处理，搜索下面是否含有
///具体的实现类包括：IfStatement、Block、FunctionDeclaration
}