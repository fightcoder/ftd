import 'package:kernel/ast.dart';
import 'package:front_end/src/fasta/kernel/internal_ast.dart';

import 'store_utils.dart';

///根据项目的配置生成代码，达到类似反射的效果
class ReflectTransform extends RecursiveVisitor<void> {

@override
  void visitClass(Class node) {
  super.visitClass(node);
  if(node.name == 'TestMgm'){
    print('reflect TestMgm');

    ///构建获取的方法
    final List<Statement> statements = <Statement>[];
    final VariableDeclarationImpl mapVariableDeclaration = VariableDeclarationImpl('fieldMapData',0,initializer: MapLiteral(<MapEntry>[]),);
    statements.add(mapVariableDeclaration);
    final List<Field> fields = node.fields;
    for(Field field in fields){
      final PropertyGet propertyGet = PropertyGet.byReference(ThisExpression(),Name(field.name.name,node.parent),field.reference);
      final Arguments arguments = Arguments(<Expression>[StringLiteral(field.name.name),propertyGet]);
      final MethodInvocation methodInvocation = MethodInvocation(VariableGetImpl(mapVariableDeclaration,null,null,forNullGuardedAccess: false),Name('[]='),arguments);
      final  ExpressionStatement expressionsStatement = ExpressionStatement(methodInvocation);
      statements.add(expressionsStatement);
    }
    ///构建returnStatement
    final  ReturnStatement returnStatement = ReturnStatementImpl(false,VariableGetImpl(mapVariableDeclaration,null,null,forNullGuardedAccess: false));
    statements.add(returnStatement);
    final  FunctionNode functionNode = FunctionNode(Block(statements));
    final  Procedure procedure = Procedure(Name('getFields'),ProcedureKind.Method,functionNode);
    node.proceduresInternal.add(procedure);

    ///构建对属性重新赋值的方法
    ///入参
    final VariableDeclarationImpl filedNameParameterVariable = VariableDeclarationImpl('fieldName',0,type: InterfaceType.byReference(Stores.stringReference, Nullability.legacy, <DartType>[]));
    final VariableDeclarationImpl fieldValueParameterVariable = VariableDeclarationImpl('value',0,type: const DynamicType());

    final List<Statement> setFieldStatements = <Statement>[];
    final VariableDeclarationImpl fieldIndexVariable = VariableDeclarationImpl('fieldIndex',0,initializer: IntJudgment(0,'0'),type: InterfaceType.byReference(Stores.intReference,Nullability.legacy,<DartType>[]));
    setFieldStatements.add(fieldIndexVariable);

    final MethodInvocation methodInvocation = MethodInvocation(ThisExpression(),Name('getFields'),ArgumentsImpl(<Expression>[]));
    final VariableDeclarationImpl fieldsMapVariable = VariableDeclarationImpl('fields',0,initializer:methodInvocation,type: const DynamicType());
    setFieldStatements.add(fieldsMapVariable);

    final ArgumentsImpl argumentsImpl = ArgumentsImpl(<Expression>[VariableGet(fieldsMapVariable)],types: <DartType>[const DynamicType(),const DynamicType()]);
    final FactoryConstructorInvocationJudgment linkedMapjudgment = FactoryConstructorInvocationJudgment(Stores.linkHashMapFromProcedure ,argumentsImpl);//Reference to dart:collection::LinkedHashMap::@factories::from
    final VariableDeclarationImpl fieldsLinkedMapVariable = VariableDeclarationImpl('fieldsLinkMap',0,initializer:linkedMapjudgment,type: const DynamicType() );
    setFieldStatements.add(fieldsLinkedMapVariable);

    final PropertyGet keysPropertyGet = PropertyGet(VariableGetImpl(fieldsLinkedMapVariable,null,null,forNullGuardedAccess: false),Name('keys'));//差Reference to dart:core::Map::@getters::keys
    VariableDeclarationImpl keysVariable = VariableDeclarationImpl('keys',0,initializer:keysPropertyGet,type: const DynamicType());
    setFieldStatements.add(keysVariable);

    final VariableDeclarationImpl keyFieldVariable = VariableDeclarationImpl('field',0,type: const DynamicType());
    final VariableGetImpl iterableVariableGetImpl = VariableGetImpl(keysVariable,null,null,forNullGuardedAccess: false);
    final VariableGetImpl fieldIndexVariableGet = VariableGetImpl(fieldIndexVariable,null,null,forNullGuardedAccess: false);
    ///+1的statement 【expressionStatement】
    final  ExpressionStatement expressionStatement = ExpressionStatement(VariableSet(fieldIndexVariable,MethodInvocation(fieldIndexVariableGet,Name('+'),Arguments(<Expression>[IntJudgment(1,null)]))));//Reference to dart:core::num::@methods::+
    VariableDeclarationImpl fieldNameVariable = VariableDeclarationImpl('fieldName',0);
    final MethodInvocation equasMethodInvocation = MethodInvocation(VariableGetImpl(keyFieldVariable,null,null,forNullGuardedAccess: false),Name('=='),
        Arguments(<Expression>[VariableGetImpl(filedNameParameterVariable,null,null,forNullGuardedAccess: false)]));//Reference to dart:core::Object::@methods::==
    final BreakStatementImpl thenBreakStatementImpl = BreakStatementImpl(isContinue: false);
    final Block thenBlock = Block(<Statement>[thenBreakStatementImpl]);
    final IfStatement ifStatement = IfStatement(equasMethodInvocation,thenBlock,null);
    final  Block block = Block(<Statement>[ifStatement,expressionStatement]);
    final  ForInStatement findIndexforInStatement = ForInStatement(keyFieldVariable,iterableVariableGetImpl,block);
    thenBreakStatementImpl.targetStatement = findIndexforInStatement;
    final LabeledStatement labeledStatement = LabeledStatement(findIndexforInStatement);
    thenBreakStatementImpl.target = labeledStatement;
    setFieldStatements.add(labeledStatement);
    ///开始循环加入属性,switch
    List<SwitchCaseImpl> cases = <SwitchCaseImpl>[];
    SwitchStatement  switchStatement = SwitchStatement(VariableGetImpl(fieldIndexVariable,null,null,forNullGuardedAccess: false),cases);
    LabeledStatement labeledStatement2 = LabeledStatement(switchStatement);//带break的statement会带这个Label，编译后的dill会有一个标识label退出
    for(int index = 0;index < fields.length;index++){
      final Field field = fields[index];
      ExpressionStatement expressionStatement1 = ExpressionStatement(PropertySet.byReference(ThisExpression(),field.name,AsExpression(VariableGetImpl(fieldValueParameterVariable
          ,null,null,forNullGuardedAccess: false),InterfaceType.byReference(Stores.intReference, Nullability.legacy, <DartType>[])),field.reference));
      BreakStatementImpl breakStatementImpl1 = BreakStatementImpl(isContinue: false);
      Block block2 = Block(<Statement>[expressionStatement1,breakStatementImpl1]);
      SwitchCaseImpl caseImpl = SwitchCaseImpl(<Expression>[IntJudgment(index,'$index')],<int>[600+index*3],block2,hasLabel: false);
      cases.add(caseImpl);
      breakStatementImpl1.targetStatement = switchStatement;
      breakStatementImpl1.target = labeledStatement2;
    }
    setFieldStatements.add(labeledStatement2);

    FunctionNode functioNode2 = FunctionNode(Block(setFieldStatements));
    Procedure procedure2 = Procedure(Name('setField'),ProcedureKind.Method,functioNode2);
    ///添加方法的入参
    functioNode2.positionalParameters = <VariableDeclaration>[filedNameParameterVariable,fieldValueParameterVariable];
    functioNode2.requiredParameterCount = functioNode2.positionalParameters.length;
    functioNode2.returnType = const VoidType();
    node.proceduresInternal.add(procedure2);
  }
  }
}