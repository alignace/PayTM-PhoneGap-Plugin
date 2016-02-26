#import "PayTMCordova.h"
#import <Cordova/CDV.h>

@implementation PayTMCordova{
    NSString* callbackId;
    PGTransactionViewController* txnController;
}

- (void)startPayment:(CDVInvokedUrlCommand *)command {
    
    callbackId = command.callbackId;
//    orderId, customerId, email, phone, amount,
    NSString *orderId  = [command.arguments objectAtIndex:0];
    NSString *customerId = [command.arguments objectAtIndex:1];
    NSString *email = [command.arguments objectAtIndex:2];
    NSString *phone = [command.arguments objectAtIndex:3];
    NSString *amount = [command.arguments objectAtIndex:4];
    
    NSBundle* mainBundle;
    mainBundle = [NSBundle mainBundle];
    
    NSString* paytm_generate_url = [mainBundle objectForInfoDictionaryKey:@"PayTMGenerateChecksumURL"];
    NSString* paytm_validate_url = [mainBundle objectForInfoDictionaryKey:@"PayTMVerifyChecksumURL"];
    NSString* paytm_merchant_id = [mainBundle objectForInfoDictionaryKey:@"PayTMMerchantID"];
    NSString* paytm_ind_type_id = [mainBundle objectForInfoDictionaryKey:@"PayTMIndustryTypeID"];
    NSString* paytm_website = [mainBundle objectForInfoDictionaryKey:@"PayTMWebsite"];
    
    //Step 1: Create a default merchant config object
    PGMerchantConfiguration* merchant = [PGMerchantConfiguration defaultConfiguration];
    
    //Step 2: If you have your own checksum generation and validation url set this here. Otherwise use the default Paytm urls
    merchant.checksumGenerationURL = paytm_generate_url;
    merchant.checksumValidationURL = paytm_validate_url;
    
    //Step 3: Create the order with whatever params you want to add. But make sure that you include the merchant mandatory params
    NSMutableDictionary *orderDict = [NSMutableDictionary new];
    //Merchant configuration in the order object
    //orderDict[@"REQUEST_TYPE"] = @"DEFAULT";
    orderDict[@"CHANNEL_ID"] = @"WAP";
    orderDict[@"THEME"] = @"merchant";
    orderDict[@"INDUSTRY_TYPE_ID"] = paytm_ind_type_id;
    orderDict[@"MID"] = paytm_merchant_id;
    orderDict[@"WEBSITE"] = paytm_website;
    
    //Order configuration in the order object
    orderDict[@"TXN_AMOUNT"] = amount;
    orderDict[@"ORDER_ID"] = orderId;
    orderDict[@"CUST_ID"] = customerId;
    orderDict[@"EMAIL"] = email;
    orderDict[@"MOBILE_NO"] = phone;
    
    PGOrder *order = [PGOrder orderWithParams:orderDict];
    
    //Step 4: Choose the PG server.
    txnController = [[PGTransactionViewController alloc] initTransactionForOrder:order];
    txnController.serverType = eServerTypeProduction;
    txnController.merchant = merchant;
    txnController.delegate = self;
    //txnController.loggingEnabled = true;
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 64.0f)];
    headerView.backgroundColor = [UIColor clearColor];
    UIView * topBar = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 20.0f, 320.0f, 50.0f)];
    [topBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"topBar"]]];
    [headerView addSubview:topBar];
    txnController.topBar = headerView;
    
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(10.0f, 25.0f, 60.0f, 40.0f)];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    txnController.cancelButton = cancelButton;
    
    
    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
//    [rootVC.navigationController pushViewController:txnController animated:true];
    [rootVC presentViewController:txnController animated:YES completion:nil];
}

//Called when a transaction has completed. response dictionary will be having details about Transaction.
- (void)didSucceedTransaction:(PGTransactionViewController *)controller
                     response:(NSDictionary *)response{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    [txnController dismissViewControllerAnimated:YES completion:nil];
}

//Called when a transaction is failed with any reason. response dictionary will be having details about failed Transaction.
- (void)didFailTransaction:(PGTransactionViewController *)controller
                     error:(NSError *)error
                  response:(NSDictionary *)response{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:response];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    [txnController dismissViewControllerAnimated:YES completion:nil];
    
}

//Called when a transaction is Canceled by User. response dictionary will be having details about Canceled Transaction.
- (void)didCancelTransaction:(PGTransactionViewController *)controller
                       error:(NSError *)error
                    response:(NSDictionary *)response{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:response];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    [txnController dismissViewControllerAnimated:YES completion:nil];
}

@end
