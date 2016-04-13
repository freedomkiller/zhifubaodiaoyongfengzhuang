//
//  AlipayRequestConfig.m
//  支付宝支付方法封装
//
//  Created by fairy on 16/4/5.
//  Copyright © 2016年 fairy. All rights reserved.
//

#import "AlipayRequestConfig.h"

@implementation AlipayRequestConfig
//仅含有变化的参数
+(void)alipayWithPartner:(NSString *)partner seller:(NSString *)seller tradeNO:(NSString *)tradeNO productName:(NSString *)productName productDescription:(NSString *)productDescription amount:(NSString *)amount notifyURL:(NSString *)notifyURL itBPay:(NSString *)itBPay
{
    [self alipayWithPartner:partner seller:seller tradeNO:tradeNO productName:productName productDescription:productDescription amount:amount notifyURL:notifyURL service:@"mobile.securitypay.pay" paymentType:@"1" inputCharset:@"UTF-8" itBPay:itBPay privateKey:kPrivateKey appScheme:kAppScheme];
}

+(void)alipayWithPartner:(NSString *)partner seller:(NSString *)seller tradeNO:(NSString *)tradeNO productName:(NSString *)productName productDescription:(NSString *)productDescription amount:(NSString *)amount notifyURL:(NSString *)notifyURL service:(NSString *)service paymentType:(NSString *)paymentType inputCharset:(NSString *)inputCharset itBPay:(NSString *)itBPay privateKey:(NSString *)privateKey appScheme:(NSString *)appScheme
{
    Order *order = [Order order];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = tradeNO;
    order.productName = productName;
    order.productDescription = productDescription;
    order.amount = amount;
    order.notifyURL = notifyURL;
    order.service = service;
    order.paymentType = paymentType;
    order.inputCharset = inputCharset;
    order.itBPay = itBPay;
    
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    //获取私钥并将商户信息签名，外部商户可以根据情况存放私钥和签名，只需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    NSString * signedString = [self SignedSteingWithPrivateKey:kPrivateKey OrderSpec:orderSpec];
    //调用支付接口
    [self payWithAppScheme:appScheme orderSpec:orderSpec signedString:signedString];
}

//生成signedString
+(NSString *)SignedSteingWithPrivateKey:(NSString *)privateKey OrderSpec:(NSString *)orderSpec
{
    //获取私钥并将商户信息签名，外部商户可以根据情况存放私钥和签名，只需要遵循RSA 签名规范，并将签名字符串 base64 编码和 urlEncode
    id<DataSigner> singer = CreateRSADataSigner(privateKey);
    return [singer signString:orderSpec];
}

//支付
+(void)payWithAppScheme:(NSString *)appScheme orderSpec:(NSString *)orderSpec signedString:(NSString *)signedString
{
    //将签名成功字符串格式化为订单字符串，请严格按照该格式
    NSString * orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", orderSpec, signedString, @"RSA"];
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);

        }];
    }
}

@end
