package hydra.langs.sql.ansi;

public class ReferenceScopeCheck {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/langs/sql/ansi.ReferenceScopeCheck");
  
  public ReferenceScopeCheck () {
  
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof ReferenceScopeCheck)) {
      return false;
    }
    ReferenceScopeCheck o = (ReferenceScopeCheck) (other);
    return true;
  }
  
  @Override
  public int hashCode() {
    return 0;
  }
}