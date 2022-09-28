package hydra.ext.graphql.syntax;

public class EnumTypeExtension_Sequence {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/ext/graphql/syntax.EnumTypeExtension.Sequence");
  
  public final hydra.ext.graphql.syntax.Name name;
  
  public final java.util.Optional<hydra.ext.graphql.syntax.Directives> directives;
  
  public final hydra.ext.graphql.syntax.EnumValuesDefinition enumValuesDefinition;
  
  public EnumTypeExtension_Sequence (hydra.ext.graphql.syntax.Name name, java.util.Optional<hydra.ext.graphql.syntax.Directives> directives, hydra.ext.graphql.syntax.EnumValuesDefinition enumValuesDefinition) {
    this.name = name;
    this.directives = directives;
    this.enumValuesDefinition = enumValuesDefinition;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof EnumTypeExtension_Sequence)) {
      return false;
    }
    EnumTypeExtension_Sequence o = (EnumTypeExtension_Sequence) (other);
    return name.equals(o.name) && directives.equals(o.directives) && enumValuesDefinition.equals(o.enumValuesDefinition);
  }
  
  @Override
  public int hashCode() {
    return 2 * name.hashCode() + 3 * directives.hashCode() + 5 * enumValuesDefinition.hashCode();
  }
  
  public EnumTypeExtension_Sequence withName(hydra.ext.graphql.syntax.Name name) {
    return new EnumTypeExtension_Sequence(name, directives, enumValuesDefinition);
  }
  
  public EnumTypeExtension_Sequence withDirectives(java.util.Optional<hydra.ext.graphql.syntax.Directives> directives) {
    return new EnumTypeExtension_Sequence(name, directives, enumValuesDefinition);
  }
  
  public EnumTypeExtension_Sequence withEnumValuesDefinition(hydra.ext.graphql.syntax.EnumValuesDefinition enumValuesDefinition) {
    return new EnumTypeExtension_Sequence(name, directives, enumValuesDefinition);
  }
}