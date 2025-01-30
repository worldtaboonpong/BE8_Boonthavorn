@isTest
public class CustomMetadataCallback_Test {
    @isTest
    static void testhandleResult() {
        Metadata.DeployCallback callback = new CustomMetadataCallback();
        Metadata.DeployResult result = new Metadata.DeployResult();
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
        callback.handleResult(result, context);
    }
}