// Transformer/visitor for toString
// If we add any more of these, they really should go into a separate library.

import 'package:kernel/ast.dart';
import 'package:vm/target/flutter.dart';
import 'click_shake_transform.dart';
import 'function_log_transform.dart';
import 'store_utils.dart';

class FtTransformer extends FlutterProgramTransformer {
  /// The [packageUris] parameter must not be null, but may be empty.
  FtTransformer();

  Component platformStrongComponent;

  @override
  void transform(Component component) {
    getInfoForStore(component);
    component.visitChildren(FunctionDebugTransform());
    component.visitChildren(ClickShakeTransform());
  }

  void getInfoForStore(Component component){
    final List<Library> libraries = component.libraries;
    if (libraries.isEmpty) {
      return;
    }
    final List<Library> concatLibraries = <Library>[
      ...libraries,
      ...platformStrongComponent != null
          ? platformStrongComponent.libraries
          : <Library>[]
    ];
    for (Library library in concatLibraries) {
      if(library.name == 'shake_handle_help'){
        for(Procedure procedure in library.procedures){
          Stores.isDoubleClickReference = procedure.reference;
        }
      }
      if(library.name == 'dart.core'){
        for(Procedure procedure in library.procedures){
          if(procedure.name.name == 'print'){
            Stores.printProcedure = procedure;
            break;
          }
        }
        for(Class cls in library.classes){
          final String clsName = cls.name;
          if(clsName == 'int'){
            Stores.intReference = cls.reference;
          }else if(clsName == 'String'){
            Stores.stringReference = cls.reference;
          }else if(clsName == 'Map'){
            Stores.mapReference = cls.reference;
          }else if(clsName == 'DateTime'){
            for(Constructor constructor in cls.constructorsInternal){
              if(constructor.name.name == 'now'){
                Stores.dateTimeNowConstructor = constructor;
              }
            }
          }
        }
      }
      if(library.name == 'dart.collection'){
        for(Class cls in library.classes){
          final String clsName = cls.name;
          if (clsName == 'LinkedHashMap'){
            for(Procedure procedure in cls.proceduresInternal){
              if(procedure.name.name == 'from'){
                Stores.linkHashMapFromProcedure = procedure;
              }
            }
          }
        }
      }
    }
  }
}
