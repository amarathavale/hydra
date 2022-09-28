package hydra.ext.graphql.syntax;

public class ObjectTypeExtension_Sequence {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/ext/graphql/syntax.ObjectTypeExtension.Sequence");
  
  public final hydra.ext.graphql.syntax.Name name;
  
  public final java.util.Optional<hydra.ext.graphql.syntax.ImplementsInterfaces> implementsInterfaces;
  
  public final java.util.Optional<hydra.ext.graphql.syntax.Directives> directives;
  
  public final hydra.ext.graphql.syntax.FieldsDefinition fieldsDefinition;
  
  public ObjectTypeExtension_Sequence (hydra.ext.graphql.syntax.Name name, java.util.Optional<hydra.ext.graphql.syntax.ImplementsInterfaces> implementsInterfaces, java.util.Optional<hydra.ext.graphql.syntax.Directives> directives, hydra.ext.graphql.syntax.FieldsDefinition fieldsDefinition) {
    this.name = name;
    this.implementsInterfaces = implementsInterfaces;
    this.directives = directives;
    this.fieldsDefinition = fieldsDefinition;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof ObjectTypeExtension_Sequence)) {
      return false;
    }
    ObjectTypeExtension_Sequence o = (ObjectTypeExtension_Sequence) (other);
    return name.equals(o.name) && implementsInterfaces.equals(o.implementsInterfaces) && directives.equals(o.directives) && fieldsDefinition.equals(o.fieldsDefinition);
  }
  
  @Override
  public int hashCode() {
    return 2 * name.hashCode() + 3 * implementsInterfaces.hashCode() + 5 * directives.hashCode() + 7 * fieldsDefinition.hashCode();
  }
  
  public ObjectTypeExtension_Sequence withName(hydra.ext.graphql.syntax.Name name) {
    return new ObjectTypeExtension_Sequence(name, implementsInterfaces, directives, fieldsDefinition);
  }
  
  public ObjectTypeExtension_Sequence withImplementsInterfaces(java.util.Optional<hydra.ext.graphql.syntax.ImplementsInterfaces> implementsInterfaces) {
    return new ObjectTypeExtension_Sequence(name, implementsInterfaces, directives, fieldsDefinition);
  }
  
  public ObjectTypeExtension_Sequence withDirectives(java.util.Optional<hydra.ext.graphql.syntax.Directives> directives) {
    return new ObjectTypeExtension_Sequence(name, implementsInterfaces, directives, fieldsDefinition);
  }
  
  public ObjectTypeExtension_Sequence withFieldsDefinition(hydra.ext.graphql.syntax.FieldsDefinition fieldsDefinition) {
    return new ObjectTypeExtension_Sequence(name, implementsInterfaces, directives, fieldsDefinition);
  }
}