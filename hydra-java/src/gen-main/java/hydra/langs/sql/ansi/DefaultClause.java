package hydra.langs.sql.ansi;

public class DefaultClause {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/langs/sql/ansi.DefaultClause");
  
  public DefaultClause () {
  
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof DefaultClause)) {
      return false;
    }
    DefaultClause o = (DefaultClause) (other);
    return true;
  }
  
  @Override
  public int hashCode() {
    return 0;
  }
}