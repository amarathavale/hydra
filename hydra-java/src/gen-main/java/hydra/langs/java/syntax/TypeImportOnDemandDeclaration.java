package hydra.langs.java.syntax;

public class TypeImportOnDemandDeclaration {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/langs/java/syntax.TypeImportOnDemandDeclaration");
  
  public final hydra.langs.java.syntax.PackageOrTypeName value;
  
  public TypeImportOnDemandDeclaration (hydra.langs.java.syntax.PackageOrTypeName value) {
    this.value = value;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof TypeImportOnDemandDeclaration)) {
      return false;
    }
    TypeImportOnDemandDeclaration o = (TypeImportOnDemandDeclaration) (other);
    return value.equals(o.value);
  }
  
  @Override
  public int hashCode() {
    return 2 * value.hashCode();
  }
}