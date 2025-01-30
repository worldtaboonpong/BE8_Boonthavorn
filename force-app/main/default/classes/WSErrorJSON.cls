public class WSErrorJSON {
    public class Root_object {
    public ErrorCls error { get; set; }
  }

  public class ErrorCls {
    public String messageTH { get; set; }
    public String serverTransactionID { get; set; }
    public String message { get; set; }
    public String serverDateTime { get; set; }
    public String clientTransactionID { get; set; }
    public String code { get; set; }
  }

  public static Root_object parse(String jsonStr) {
    return (Root_object) System.JSON.deserialize(jsonStr, Root_object.class);
  }
}