using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using BusinessLogic;
using PaymentProccesor.CWSServiceInformation;
using PaymentProccesor.CwsTransactionProcessing;
using Payswyft.Log;
using UtilityServices.Enums;
using ApplicationLocation = PaymentProccesor.CWSServiceInformation.ApplicationLocation;
using CustomerPresent = PaymentProccesor.CwsTransactionProcessing.CustomerPresent;
using EntryMode = PaymentProccesor.CwsTransactionProcessing.EntryMode;
using HardwareType = PaymentProccesor.CWSServiceInformation.HardwareType;
using IndustryType = PaymentProccesor.CwsTransactionProcessing.IndustryType;
using PINCapability = PaymentProccesor.CWSServiceInformation.PINCapability;
using ReadCapability = PaymentProccesor.CWSServiceInformation.ReadCapability;
using TypeISOCurrencyCodeA3 = PaymentProccesor.CwsTransactionProcessing.TypeISOCurrencyCodeA3;

namespace Payswyft.PaymentProccesing
{
    public class IPCommerceConfig : ConfigSettings
    {
        public IPCommerceConfig(DataClassesDataContext DB)
            : base(DB, "IPCOMMERCE")
        {
        }

        public String IDENTITY_TOKEN
        {
            get { return Get("IDENTITY_TOKEN"); }
        }

        public String PTLS_SOCKET_ID
        {
            get { return Get("PTLS_SOCKET_ID"); }
        }

        public String PIN_CAPABILITY
        {
            get { return Get("PIN_CAPABILITY"); }
        }

        public String READ_CAPABILITY
        {
            get { return Get("READ_CAPABILITY"); }
        }

        public String INDUSTRY_TYPE
        {
            get { return Get("INDUSTRY_TYPE"); }
        }

        public String CUSTOMER_PRESENT
        {
            get { return Get("CUSTOMER_PRESENT"); }
        }

        public String REQUEST_ACI
        {
            get { return Get("REQUEST_ACI"); }
        }

        public String TXNDATA_PRCCESS_AS_KEY
        {
            get { return Get("TXNDATA_PRCCESS_AS_KEY"); }
        }

        public String TXNDATA_ENTRY_MODE
        {
            get { return Get("TXNDATA_ENTRY_MODE"); }
        }

        public String TXNDATA_ORDER_OF_PROCESSING_TRACKS
        {
            get { return Get("TXNDATA_ORDER_OF_PROCESSING_TRACKS"); }
        }

        public String TXNDATA_INDUSTRY_TYPE
        {
            get { return Get("TXNDATA_INDUSTRY_TYPE"); }
        }

        public String TXNDATA_CUSTOMER_PRESENT
        {
            get { return Get("TXNDATA_CUSTOMER_PRESENT"); }
        }

        public String TXNDATA_SIGNATURE_CAPTURE
        {
            get { return Get("TXNDATA_SIGNATURE_CAPTURE"); }
        }

        public String TXNDATA_INCLUDE_AVS
        {
            get { return Get("TXNDATA_INCLUDE_AVS"); }
        }

        public String TXNDATA_INCLUDE_CV
        {
            get { return Get("TXNDATA_INCLUDE_CV"); }
        }

        public String TXNDATA_INCLUDE_VPAS
        {
            get { return Get("TXNDATA_INCLUDE_VPAS"); }
        }

        public String TXNDATA_INCLUDE_UCAF
        {
            get { return Get("TXNDATA_INCLUDE_UCAF"); }
        }

        public String TXNDATA_INCLUDE_CFEES
        {
            get { return Get("TXNDATA_INCLUDE_CFEES"); }
        }

        public String PROCESS_AS_BANKCARD_TRANSACTION_PRO
        {
            get { return Get("PROCESS_AS_BANKCARD_TRANSACTION_PRO"); }
        }

        public String PRO_PURCHASE_CARD_LEVEL
        {
            get { return Get("PRO_PURCHASE_CARD_LEVEL"); }
        }

        public String PRO_INTERCHANGE_DATA
        {
            get { return Get("PRO_INTERCHANGE_DATA"); }
        }

        public String PRO_INCLUDE_LEVEL_2_3_DATA
        {
            get { return Get("PRO_INCLUDE_LEVEL_2_3_DATA"); }
        }

        public String SERVICE_ACTIVATION_KEY
        {
            get { return Get("SERVICE_ACTIVATION_KEY"); }
        }

        public String BASE_SVC_END_POINT_PRIMARY
        {
            get { return Get("BASE_SVC_END_POINT_PRIMARY"); }
        }

        public String BASE_SVC_END_POINT_SECONDARY
        {
            get { return Get("BASE_SVC_END_POINT_SECONDARY"); }
        }

        public String BASE_TXN_END_POINT_PRIMARY
        {
            get { return Get("BASE_TXN_END_POINT_PRIMARY"); }
        }

        public String BASE_TXN_END_POINT_SECONDARY
        {
            get { return Get("BASE_TXN_END_POINT_SECONDARY"); }
        }

        public String BASE_DATA_SERVICES_END_POINT_PRIMARY
        {
            get { return Get("BASE_DATA_SERVICES_END_POINT_PRIMARY"); }
        }

        public String BASE_DATA_SERVICES_END_POINT_SECONDARY
        {
            get { return Get("BASE_DATA_SERVICES_END_POINT_SECONDARY"); }
        }

        public String SERVICE_ID
        {
            get { return Get("SERVICE_ID"); }
        }

        public String PROFILE_ID
        {
            get { return Get("PROFILE_ID"); }
        }
    }

    /// <summary>
    /// IPCommerce processor
    /// </summary>
    public class IPCommerceProcessor : PaymentProcesor
    {
        private static readonly object svcInfoChannelLock = new object();
        private readonly object bankCardChannelLock = new object();
        private readonly IPCommerceConfig ipCommerceConfig;
        private ApplicationData AppData;

        private CWSServiceInformationClient CWSSIC;
        private CwsTransactionProcessingClient CWSTPC;
        private string dtSessionToken = DateTime.Now.ToString();

        // :TODO: add to merchant table mer_IPServiceID and mer_IPProfileID 
        // retrieve value(s) during PrepareToTransact()

        private string strApplicationProfileID = ""; // value dynamically retreived
        private string strProfileID = "";
        private string strServiceID = "";
        private string strSessionToken = "";

        public IPCommerceProcessor()
        {
            ipCommerceConfig = new IPCommerceConfig(new DataClassesDataContext());
        }

        public IPCommerceProcessor(DataClassesDataContext DB)
        {
            ipCommerceConfig = new IPCommerceConfig(DB);
        }

        public override bool initiatePayment()
        {
            LogRequest("initiatePayment", "start");
            Errors.Clear();

            var BCResponse = new BankcardTransactionResponse();

            if (string.IsNullOrEmpty((string) PaymentData["TokenID"]))
            {                
                BCResponse = GetCreditCardTokenID(PaymentData["Number"].ToString(),
                                                  ((DateTime) PaymentData["ExpDate"]).ToString("MMyy"),
                                                  (int) ((PayCrediCard) PaymentData).Type);
                PaymentData["TokenID"] = BCResponse.PaymentAccountDataToken;

                if (string.IsNullOrEmpty((string) PaymentData["TokenID"]))
                {
                    Errors.Add(1, "Unable to generate a valid payment account data token");
                    return false;
                }
            }

            var PayingInvoiceID = (int) PaymentData["InvoiceID"];
            var userHostAddress = (string) PaymentData["UserHostAddress"];
            var sessionID = (string) PaymentData["SessionID"];
            var Amount = (decimal) PaymentData["Amount"];
            var AddressLine1 = (string) PaymentData["AddressLine1"];
            var AddressLine2 = (string) PaymentData["AddressLine2"];
            var PostCode = (string) PaymentData["PostalCode"];
            var Town = (string) PaymentData["Town"];
            var Country = (string) PaymentData["Country"];

            var DB = new DataClassesDataContext();
            var billingAddress = new Address();

            billingAddress.add_AddressLine1 = AddressLine1;
            billingAddress.add_AddressLine2 = AddressLine2;
            billingAddress.add_DateModified = DateTime.Now;
            billingAddress.add_IsDeleted = false;
            billingAddress.add_PostalCode = PostCode;
            billingAddress.add_Town = Town;
            billingAddress.add_Country = Country;
            billingAddress.Add(DB);

            var cc = new CreditCard();
            cc.cca_AddressID = billingAddress.add_ID;
            cc.cca_CardNumber = BCResponse.MaskedPAN;
            cc.cca_IsDeleted = false;
            cc.cca_IsActive = true;
            cc.cca_Ref = (string) PaymentData["TransactionID"];
            cc.cca_Is3DS = false;
            cc.cca_ExpirationDate = ((PayCrediCard) PaymentData).ExpirationDate;
            cc.cca_DateModified = DateTime.Now;
            cc.cca_NameOnCard = ((PayCrediCard) PaymentData).HolderName;
            cc.cca_IssueNumber = ((PayCrediCard) PaymentData).IssueNumber;
            cc.CVV = ((PayCrediCard) PaymentData).CVV;
            cc.cca_CardType = (short) ((PayCrediCard) PaymentData).Type;
            cc.cca_IPCTokenID = (string) PaymentData["TokenID"];
            cc.Add(DB);

            var payment = new Payment();
            payment.pay_CreditCardID = cc.cca_ID;
            payment.pay_IsPaidByService = false;
            payment.pay_TypeID = (int) PaymentTypeEnum.CreditCard;
            payment.pay_StatusID = (int) PaymentStatusEnum.Initiated;
            payment.pay_InvoiceID = PayingInvoiceID;
            payment.pay_UserID = null; //logged user
            payment.pay_DateModified = DateTime.Now;
            payment.pay_DatePaid = DateTime.Now;
            payment.pay_IP = userHostAddress;
            payment.pay_Amount = Amount;
            payment.pay_UserID = null;
            payment.pay_Email = PaymentData["Email"].ToString();
            ;
            payment.pay_UsedPP = Convert.ToInt32(PaymentProcessorEnum.IPCommerce);
            payment.pay_InternalRefID = (string) PaymentData["TransactionID"];
            payment.pay_ExternalRefID = BCResponse.TransactionId;
            payment.CreditCard = cc;
            payment.Add(DB, userHostAddress, sessionID);

            PaymentData["PaymentID"] = payment.pay_ID;
            PaymentData["TransactionID"] = "PID_" + PaymentData["PaymentID"].ToString().PadLeft(7, '0');

            return Errors.Count == 0;
        }

        public override bool initiatePaymentConsumer(CreditCard creditCard)
        {
            LogRequest("initiatePaymentConsumer", "start");

            Errors.Clear();

            var BCResponse = new BankcardTransactionResponse();

            if (string.IsNullOrEmpty((string) PaymentData["TokenID"]))
            {
                BCResponse = GetCreditCardTokenID(PaymentData["Number"].ToString(),
                                                  ((DateTime) PaymentData["ExpDate"]).ToString("MMyy"),
                                                  (int) ((PayCrediCard) PaymentData).Type);
                PaymentData["TokenID"] = BCResponse.PaymentAccountDataToken;

                if (string.IsNullOrEmpty((string) PaymentData["TokenID"]))
                {
                    Errors.Add(1, "Unable to generate a valid payment account data token");
                    return false;
                }
            }
            else
            {
                LogRequest("initiatePaymentConsumer", "Token=" + (string) PaymentData["TokenID"]);
            }

            var PayingInvoiceID = (int?) PaymentData["InvoiceID"];
            var userHostAddress = (string) PaymentData["UserHostAddress"];
            var sessionID = (string) PaymentData["SessionID"];
            var Amount = (decimal) PaymentData["Amount"];
            var AddressLine1 = (string) PaymentData["AddressLine1"];
            var AddressLine2 = (string) PaymentData["AddressLine2"];
            var PostCode = (string) PaymentData["PostalCode"];
            var Town = (string) PaymentData["Town"];
            var Country = (string) PaymentData["Country"];

            var DB = new DataClassesDataContext();
            /*var billingAddress = new Address();

            billingAddress.add_AddressLine1 = AddressLine1;
            billingAddress.add_AddressLine2 = AddressLine2;
            billingAddress.add_DateModified = DateTime.Now;
            billingAddress.add_IsDeleted = false;
            billingAddress.add_PostalCode = PostCode;
            billingAddress.add_Town = Town;
            billingAddress.add_Country = Country;
            billingAddress.Add(DB);*/

            creditCard.cca_IsDeleted = false;
            creditCard.cca_IsActive = true;
            creditCard.cca_Ref = (string) PaymentData["TransactionID"];
            creditCard.cca_IPCTokenID = (string) PaymentData["TokenID"];
            creditCard.cca_Is3DS = false;

            var payment = new Payment();
            payment.pay_IsPaidByService = false;
            payment.pay_TypeID = (int) PaymentTypeEnum.CreditCard;
            payment.pay_StatusID = (int) PaymentStatusEnum.Initiated;
            payment.pay_InvoiceID = PayingInvoiceID;
            payment.pay_UserID = null;
            payment.pay_DateModified = DateTime.Now;
            payment.pay_DatePaid = DateTime.Now;
            payment.pay_IP = userHostAddress;
            payment.pay_Amount = Amount;
            payment.pay_UserID = null;
            payment.pay_UsedPP = Convert.ToInt32(PaymentProcessorEnum.IPCommerce);
            payment.pay_InternalRefID = (string) PaymentData["TransactionID"];


            try
            {
                payment.Add(DB, userHostAddress, sessionID);
            }
            catch (Exception ex)
            {
                LogRequest("initiatePaymentConsumer", "Error Mesage : " + ex.Message);
                LogRequest("initiatePaymentConsumer", "Error Stacktrace : " + ex.StackTrace);
            }

            PaymentData["PaymentID"] = payment.pay_ID;
            PaymentData["TransactionID"] = "PID_" + PaymentData["PaymentID"].ToString().PadLeft(7, '0');

            return Errors.Count == 0;
        }

        public override bool initiatePaymentDirectDebit()
        {
            LogRequest("initiatePaymentDirectDebit", "start");

            DataClassesDataContext DB = (DataClassesDataContext) PaymentData["DB"] ?? new DataClassesDataContext();

            DirectDebit currentDirectDebit = DirectDebit.GetByID(DB, (int) PaymentData["DirectDebitID"]);
            //Invoice currentInvoice = currentDirectDebit.Invoice; // Invoice.GetByID(DB, (int)PaymentData["InvoiceID"]);
            Invoice currentInvoice = currentDirectDebit.Invoice ?? Invoice.GetByID(DB, (int) PaymentData["InvoiceID"]);
                // Invoice.GetByID(DB, (int)PaymentData["InvoiceID"]);
            CreditCard currentCreditCard = currentDirectDebit.CreditCard;
                // CreditCard.GetById(DB, currentDirectDebit.ddd_CreditCardID);

            if (!currentDirectDebit.ddd_IsActive ||
                (currentDirectDebit.ddd_IsNumberOfPayments &&
                 currentDirectDebit.ddd_PaymentsCommited >= currentDirectDebit.ddd_NumberOfPayments.Value) ||
                (currentInvoice.inv_StatusID != (int) InvoiceStatusEnum.Outstanding &&
                 currentInvoice.inv_StatusID != (int) InvoiceStatusEnum.PartPaid) ||
                currentInvoice.inv_IsRemovedByUser ||
                currentCreditCard.cca_IsDeleted ||
                !currentCreditCard.cca_IsActive
                )
            {
                return false;
            }
            decimal amountToPay = currentInvoice.inv_DueAmount - (currentInvoice.inv_PaidAmount ?? 0);
            if (currentDirectDebit.ddd_IsSingle &&
                Convert.ToDecimal(currentDirectDebit.ddd_ScheduledPaymentAmount.Value) < amountToPay)
            {
                amountToPay = Convert.ToDecimal(currentDirectDebit.ddd_ScheduledPaymentAmount.Value);
            }

            string email;
            if (currentCreditCard.cca_UserID == null)
            {
                //E SP case, so we take the email from the first payment
                email = currentCreditCard.Payments.Last().pay_Email;
            }
            else
            {
                //E take all notification emails for that user

                //:TODO Last() exception error
                //email = ConsumerEmail.ConsumerGetSendNotificationEmails(DB, currentCreditCard.cca_UserID.Value).Last().cem_Email;

                IList<string> emails = new List<string>();
                emails =
                    ConsumerEmail.ConsumerGetSendNotificationEmails(DB, currentCreditCard.cca_UserID.Value).Select(
                        ce => ce.cem_Email).ToList();
                email = emails[emails.Count - 1];
            }

            var currentPayment = new Payment
                                     {
                                         pay_IsPaidByService = true,
                                         pay_TypeID = (int) PaymentTypeEnum.CreditCard,
                                         pay_StatusID = (int) PaymentStatusEnum.Initiated,
                                         pay_InvoiceID = (int) PaymentData["InvoiceID"],
                                         pay_CreditCardID = currentDirectDebit.CreditCard.cca_ID,
                                         // (int) PaymentData["CreditCardID"],
                                         pay_UserID = currentDirectDebit.CreditCard.cca_UserID,
                                         // (int) PaymentData["UserID"],
                                         pay_DateModified = DateTime.Now,
                                         pay_DatePaid = DateTime.Now,
                                         pay_Amount = amountToPay,
                                         // (decimal) PaymentData["Amount"],
                                         pay_Email = email,
                                         //(string) PaymentData["Email"]?? "",
                                         pay_InternalRefID = (string) PaymentData["TransactionID"],
                                         pay_ExternalRefID = (string) PaymentData["TransactionID"]
                                     };

            currentPayment.Add(DB, "", "");

            PaymentData["PaymentID"] = currentPayment.pay_ID;
            PaymentData["PaycorpCID"] = currentPayment.Invoice.Merchant.mer_PaycorpCID;
            PaymentData["Amount"] = amountToPay;
            PaymentData["TransactionID"] = "DD_PID_" + PaymentData["PaymentID"].ToString().PadLeft(7, '0');
            PaymentData["TokenID"] = currentCreditCard.cca_IPCTokenID;
            PaymentData["ExpDate"] = currentCreditCard.cca_ExpirationDate;

            return true;
        }

        public override bool completePayment()
        {
            LogRequest("completePayment", "start");

            if (PrepareToTransact())
            {
                var PayingInvoiceID = (int) PaymentData["InvoiceID"];
                var userHostAddress = (string) PaymentData["UserHostAddress"];
                var sessionID = (string) PaymentData["SessionID"];
                var Amount = (decimal) PaymentData["Amount"];
                var AddressLine1 = (string) PaymentData["AddressLine1"];
                var AddressLine2 = (string) PaymentData["AddressLine2"];
                var PostCode = (string) PaymentData["PostalCode"];
                var Town = (string) PaymentData["Town"];
                var Country = (string) PaymentData["Country"];

                var BCTransaction = new BankcardTransaction();
                var BCResponse = new BankcardTransactionResponse();

                BCTransaction = SetBankCardTxnData(null, null, 0, Amount, (string) PaymentData["TokenID"],
                                                   (string) PaymentData["TransactionID"]);
                try
                {
                    BCResponse =
                        (BankcardTransactionResponse)
                        CWSTPC.AuthorizeAndCapture(strSessionToken, BCTransaction, strApplicationProfileID, strProfileID,
                                                   strServiceID);
                }
                catch (Exception ex)
                {
                    Errors.Add(2, ex.Message);
                    LogRequest("completePayment", ex.Message);
                    return false;
                }
                LogRequest("completePayment", "status=" + BCResponse.Status +
                                              " statusCode=" + BCResponse.StatusCode +
                                              " statusMessage=" + BCResponse.StatusMessage +
                                              " amount=" + BCResponse.Amount);
                //ProcessResponse(new ResponseDetails(BCTransaction.TransactionData.Amount, BCResponse,"AuthorizeAndCapture", true));

                if (BCResponse.Status == Status.Failure)
                {
                    Errors.Add(2, BCResponse.StatusCode + " : " + BCResponse.StatusMessage);
                    return false;
                }

                var DB = new DataClassesDataContext();

                Payment payment = Payment.GetByID(DB, (int) PaymentData["PaymentID"]);
                payment.pay_StatusID = (int) PaymentStatusEnum.Paid;
                payment.pay_DateModified = DateTime.Now;
                payment.pay_DatePaid = DateTime.Now;
                payment.pay_IP = userHostAddress;
                payment.pay_UsedPP = Convert.ToInt32(PaymentProcessorEnum.IPCommerce);
                payment.pay_ResultCode = BCResponse.StatusCode;
                payment.pay_ResultMessage = BCResponse.StatusMessage;

                payment.pay_InternalRefID = (string) PaymentData["TransactionID"];
                payment.pay_ExternalRefID = BCResponse.TransactionId;

                Invoice invoice = Invoice.GetByID(DB, PayingInvoiceID);
                decimal paidAmount = invoice.inv_PaidAmount ?? 0;
                invoice.inv_StatusID =
                    (short)
                    ((Amount + paidAmount) < invoice.inv_DueAmount
                         ? (int) InvoiceStatusEnum.PartPaid
                         : (int) InvoiceStatusEnum.Paid);
                invoice.inv_PaidAmount = (invoice.inv_PaidAmount ?? 0) + Amount;
                invoice.inv_PaidDate = DateTime.Now;
                invoice.inv_IsMarkedAsPaid = false;

                payment.Update(DB, userHostAddress, sessionID);
                invoice.Update(DB);

                //Fee.InsertPaymentFee(DB, payment, false, invoice.inv_MerchantID.Value, userHostAddress, sessionID);                
            }
            else
            {
                LogRequest("completePayment", "failed to complete payment");
                Errors.Add(2, "Failed to PrepareToTransact");
                return false;
            }

            return true;
        }

        public override bool completePaymentConsumer(CreditCard creditCard)
        {
            LogRequest("completePaymentConsumer", "start");

            //var DB = new DataClassesDataContext();
            
            DataClassesDataContext DB = (DataClassesDataContext)PaymentData["DB"] ?? new DataClassesDataContext();

            if (PrepareToTransact())
            {
                var PayingInvoiceID = (int) PaymentData["InvoiceID"];
                var userHostAddress = (string) PaymentData["UserHostAddress"];
                var sessionID = (string) PaymentData["SessionID"];
                var Amount = (decimal) PaymentData["Amount"];
                var AddressLine1 = (string) PaymentData["AddressLine1"];
                var AddressLine2 = (string) PaymentData["AddressLine2"];
                var PostCode = (string) PaymentData["PostalCode"];
                var Town = (string) PaymentData["Town"];
                var Country = (string) PaymentData["Country"];

                var BCTransaction = new BankcardTransaction();
                var BCResponse = new BankcardTransactionResponse();

                BCTransaction = SetBankCardTxnData(null, null, 0, Amount, (string) PaymentData["TokenID"],
                                                   (string) PaymentData["TransactionID"]);
                try
                {
                    BCResponse =
                        (BankcardTransactionResponse)
                        CWSTPC.AuthorizeAndCapture(strSessionToken, BCTransaction, strApplicationProfileID, strProfileID,
                                                   strServiceID);
                }
                catch (Exception ex)
                {
                    Errors.Add(2, ex.Message);
                    LogRequest("completePayment", ex.Message);
                    return false;
                }
                //LogRequest("completePaymentConsumer", "status={0} statusCode={1} statusMessage={2} amount={3}", BCResponse.Status, BCResponse.StatusCode, BCResponse.StatusMessage, BCResponse.Amount);
                LogRequest("completePaymentConsumer", "status=" + BCResponse.Status +
                                                      " statusCode=" + BCResponse.StatusCode +
                                                      " statusMessage=" + BCResponse.StatusMessage + " amount=" +
                                                      BCResponse.Amount);
                //ProcessResponse(new ResponseDetails(BCTransaction.TransactionData.Amount, BCResponse,"AuthorizeAndCapture", true));

                if (BCResponse.Status == Status.Failure)
                {
                    Errors.Add(2, BCResponse.StatusCode + " : " + BCResponse.StatusMessage);
                    return false;
                }

                Payment payment = Payment.GetByID(DB, (int) PaymentData["PaymentID"]);
                payment.pay_UsedPP = Convert.ToInt32(PaymentProcessorEnum.IPCommerce);
                payment.pay_ResultCode = BCResponse.StatusCode;
                payment.pay_ResultMessage = BCResponse.StatusMessage;
                payment.pay_InternalRefID = (string) PaymentData["TransactionID"];
                payment.pay_ExternalRefID = BCResponse.TransactionId;
                payment.pay_DateModified = DateTime.Now;
                payment.Update(DB, userHostAddress, sessionID);
            }
            else
            {
                LogRequest("completePaymentConsumer", "failed to complete payment");
                Errors.Add(2, "Failed to PrepareToTransact");
                return false;
            }

            creditCard.cca_IsDeleted = false;
            creditCard.cca_IsActive = true;

            if (creditCard.cca_ID > 0)
            {
                creditCard.Update(DB);
            }
            else
            {
                creditCard.Add(DB);
            }

            DB.SubmitChanges();

            return true;
        }

        public override bool completePaymentDirectDebit(CreditCard cc)
        {
            LogRequest("completePaymentDirectDebit", "start");

            DataClassesDataContext DB = (DataClassesDataContext) PaymentData["DB"] ?? new DataClassesDataContext();
            DirectDebit currentDirectDebit = DirectDebit.GetByID(DB, (int) PaymentData["DirectDebitID"]);
            Payment currentPayment = Payment.GetByID(DB, (int) PaymentData["PaymentID"]);
            Invoice currentInvoice = currentPayment.Invoice; // Invoice.GetByID(DB, (int)PaymentData["InvoiceID"]);
            CreditCard currentCreditCard = currentPayment.CreditCard;
                // CreditCard.GetById(DB, currentDirectDebit.ddd_CreditCardID);

            PaymentData["TransactionID"] = string.Format("PID_{0}", PaymentData["PaymentID"].ToString().PadLeft(7, '0'));

            if (PrepareToTransact())
            {
                var BCTransaction = new BankcardTransaction();
                var BCResponse = new BankcardTransactionResponse();

                BCTransaction = SetBankCardTxnData(null, null, 0, (decimal) PaymentData["Amount"],
                                                   (string) PaymentData["TokenID"],
                                                   (string) PaymentData["TransactionID"]);
                try
                {
                    BCResponse =
                        (BankcardTransactionResponse)
                        CWSTPC.AuthorizeAndCapture(strSessionToken, BCTransaction, strApplicationProfileID, strProfileID,
                                                   strServiceID);
                }
                catch (Exception ex)
                {
                    Errors.Add(2, ex.Message);
                    LogRequest("completePaymentDirectDebit", ex.Message);
                    return false;
                }

                LogRequest("completePaymentDirectDebit", "status=" + BCResponse.Status +
                                                      " statusCode=" + BCResponse.StatusCode +
                                                      " statusMessage=" + BCResponse.StatusMessage + " amount=" +
                                                      BCResponse.Amount);
                //ProcessResponse(new ResponseDetails(BCTransaction.TransactionData.Amount, BCResponse,"AuthorizeAndCapture", true));

                if (BCResponse.Status == Status.Failure)
                {
                    Errors.Add(2, BCResponse.StatusCode + " : " + BCResponse.StatusMessage);

                    currentPayment.pay_StatusID = (int) PaymentStatusEnum.Failed;
                    currentPayment.pay_ResultCode = BCResponse.StatusCode;
                    currentPayment.pay_ResultMessage = BCResponse.StatusMessage;
                    currentPayment.Update(DB, "", "");

                    currentDirectDebit.ddd_NonTechnicalFailures++;
                    currentDirectDebit.ddd_TechnicalFailures++;
                    currentDirectDebit.Update(DB);

                    if (currentDirectDebit.ddd_IsRecurring && (currentDirectDebit.ddd_TechnicalFailures > 2
                                                               || currentDirectDebit.ddd_NonTechnicalFailures >= 2))
                    {
                        //E add record in the failedDDD because the allowed re-attempt are done
                        var fdd = new FailedDirectDebit
                                      {
                                          fdd_DirectDebitID = currentDirectDebit.ddd_ID,
                                          fdd_DateFailed = DateTime.Now,
                                          fdd_ErrorTypeID = (int) FailedDDErrorTypeEnum.PaymentError,
                                          fdd_InvoiceID = (int) PaymentData["InvoiceID"],
                                      };
                        fdd.Add(DB);
                    }
                    return false;
                }

                currentCreditCard.cca_Ref = "ipcommerce";
                currentCreditCard.Update(DB);

                currentPayment.pay_DatePaid = DateTime.Now;
                currentPayment.pay_StatusID = (int) PaymentStatusEnum.Paid;
                currentPayment.pay_IsPaidByService = true;
                currentPayment.Update(DB, "", "");

                currentPayment.pay_ResultCode = BCResponse.StatusCode;
                currentPayment.pay_ResultMessage = BCResponse.StatusMessage;


                var amountToPay = (decimal) PaymentData["Amount"];
                decimal paidAmount = currentInvoice.inv_PaidAmount ?? 0;

                currentInvoice.inv_StatusID =
                    (short)
                    ((amountToPay + paidAmount) < currentInvoice.inv_DueAmount
                         ? (int) InvoiceStatusEnum.PartPaid
                         : (int) InvoiceStatusEnum.Paid);
                currentInvoice.inv_PaidAmount = (currentInvoice.inv_PaidAmount ?? 0) + amountToPay;
                currentInvoice.inv_PaidDate = DateTime.Now;
                currentInvoice.inv_IsMarkedAsPaid = false;

                if (currentInvoice.inv_StatusID == (int) InvoiceStatusEnum.Paid)
                {
                    //E lock the invoice for other users if the CC has user associated
                    currentInvoice.inv_FinalOwnerID = currentCreditCard.cca_UserID;
                }

                currentInvoice.Update(DB);
                //Fee.InsertPaymentFee(DB, currentPayment, currentDirectDebit.ddd_IsRecurring, currentInvoice.inv_MerchantID.Value, "", "");
                if (currentDirectDebit.ddd_IsSingle)
                {
                    //E disable the SP
                    currentDirectDebit.ddd_IsActive = false;
                }
                else if (currentDirectDebit.ddd_IsRecurring)
                {
                    //E add record in the failedDDD just to prevent the next executions
                    var fdd = new FailedDirectDebit();
                    fdd.fdd_DirectDebitID = currentDirectDebit.ddd_ID;
                    fdd.fdd_DateFailed = DateTime.Now;
                    fdd.fdd_ErrorTypeID = (int) FailedDDErrorTypeEnum.Paid;
                    fdd.fdd_InvoiceID = currentInvoice.inv_ID;
                    fdd.Add(DB);
                }

                currentDirectDebit.ddd_PaymentsCommited++;
                currentDirectDebit.ddd_TechnicalFailures = 0;
                currentDirectDebit.ddd_NonTechnicalFailures = 0;
                currentDirectDebit.Update(DB);

                DB.SubmitChanges();
            }
            else
            {
                LogRequest("completePaymentConsumer", "failed to complete payment");
                Errors.Add(2, "Failed to PrepareToTransact");

                currentPayment.pay_StatusID = (int) PaymentStatusEnum.Failed;
                currentPayment.pay_ResultCode = "X";
                currentPayment.pay_ResultMessage = "GATEWAY ERROR";
                //currentPayment.pay_UsedPP = Convert.ToInt32(UtilityServices.Enums.PaymentProcessorEnum.IPCommerce);
                currentPayment.Update(DB, "", "");

                currentDirectDebit.ddd_NonTechnicalFailures++;
                currentDirectDebit.ddd_TechnicalFailures++;
                currentDirectDebit.Update(DB);
                return false;
            }

            LogRequest("completePaymentConsumer", "end");
            return true;
        }

        public override bool Pass3DS()
        {
            LogRequest("Pass3DS", "start");
            PaymentData["is3DS"] = false;
            return true;
        }

        public override bool Pass3DSConsumer()
        {
            LogRequest("Pass3DSConsumer", "start");
            return true;
        }

        public override bool Validate()
        {
            LogRequest("Validate", "start");
            //bool result = false;
            bool result = true;

            result = Errors.Count == 0;
            return result;
        }

        public override bool payScheduled(DateTime pPayOnDate)
        {
            LogRequest("payScheduled", "start");
            Errors.Clear();
            if ((bool) PaymentData["is3DS"])
            {
            }

            var DB = new DataClassesDataContext();
            Payment CurrentPayment = Payment.GetByID(DB, (int) PaymentData["PaymentID"]);
            Invoice CurrentInvoice = Invoice.GetByID(DB, (int) PaymentData["InvoiceID"]);
            var directDebit = new DirectDebit
                                  {
                                      ddd_BillID = null,
                                      ddd_InvoiceID = CurrentInvoice.inv_ID,
                                      ddd_IsSingle = true,
                                      ddd_IsRecurring = false,
                                      ddd_IsNoExpiryDate = true,
                                      ddd_IsExpiryDate = false,
                                      ddd_ExpiryDate = null,
                                      ddd_IsNumberOfPayments = false,
                                      ddd_NumberOfPayments = 0,
                                      ddd_PaymentsCommited = 0,
                                      ddd_IsPayFullAmount = false,
                                      ddd_IsAmountLimited = false,
                                      ddd_AmountLimit = null,
                                      ddd_ScheduledPaymentAmount = CurrentPayment.pay_Amount,
                                      ddd_IsPayUponPresentment = false,
                                      ddd_IsPayOnLastDay = false,
                                      ddd_IsPayOnFirstDay = false,
                                      ddd_IsFixedDate = true,
                                      ddd_FixedDate = pPayOnDate,
                                      ddd_IsActive = true,
                                      ddd_TechnicalFailures = 0,
                                      ddd_NonTechnicalFailures = 0,
                                      ddd_DateCreated = DateTime.Now,
                                      ddd_CreditCardID = (int) CurrentPayment.pay_CreditCardID
                                  };

            directDebit.Add(DB);
            return Errors.Count == 0;
        }

        private bool Is3DS()
        {
            LogRequest("Is3DS", "start");
            PaymentData["is3DS"] = false;
            return true;
        }

        private bool PrepareToTransact()
        {
            LogRequest("PrepareToTransact", "start");

            bool result = true;

            string mer_IPServiceID = "";
            string mer_IPProfileID = "";

            DataClassesDataContext DB = new DataClassesDataContext();

            // :BUGFIX: invoice and merchant will throw error during the merchant registration credit card section
            try
            {
                var invoice = Invoice.GetByID(DB, (int)PaymentData["InvoiceID"]);
                var merchant = invoice.Merchant;

                mer_IPProfileID = merchant.mer_IPProfileID;
                mer_IPServiceID = merchant.mer_IPServiceID;
            }
            catch (Exception) { }

            string serviceActivationKey = ipCommerceConfig.SERVICE_ACTIVATION_KEY;

            strServiceID = string.IsNullOrEmpty(mer_IPServiceID) ? ipCommerceConfig.SERVICE_ID : mer_IPServiceID;
            strProfileID = string.IsNullOrEmpty(mer_IPProfileID) ? ipCommerceConfig.PROFILE_ID : mer_IPProfileID;

            LogRequest("PrepareToTransact", "strServiceID=" + strServiceID + " strProfileID=" + strProfileID);

            if (string.IsNullOrEmpty(strServiceID) || string.IsNullOrEmpty(strProfileID))
            {
                PSLogger.Error("PrepareToTransact", "service or profile id cannot be null");
                return false;
            }

            LogRequest("PrepareToTransact", "BASE_SVC_END_POINT_PRIMARY=" + ipCommerceConfig.BASE_SVC_END_POINT_PRIMARY
                                            + " BASE_TXN_END_POINT_PRIMARY=" +
                                            ipCommerceConfig.BASE_TXN_END_POINT_PRIMARY
                                            + " SERVICE_ACTIVATION_KEY=" + ipCommerceConfig.SERVICE_ACTIVATION_KEY
                                            + " IDENTITY_TOKEN=" + ipCommerceConfig.IDENTITY_TOKEN);
            // :TODO: if fail to get primary endpoints try secondary endpoints);
            try
            {
                CWSSIC = new CWSServiceInformationClient();
                CWSTPC = new CwsTransactionProcessingClient();

                CWSSIC = GetServiceInfoChannel(serviceActivationKey, ipCommerceConfig.BASE_SVC_END_POINT_PRIMARY);
                CWSTPC = GetChannel(serviceActivationKey, ipCommerceConfig.BASE_TXN_END_POINT_PRIMARY);
            }
            catch (Exception ex)
            {
                PSLogger.Error("PrepareToTransact", "failed to get endpoint: " + ex.Message);
                return false;
            }

            strSessionToken = CWSSIC.SignOnWithToken(ipCommerceConfig.IDENTITY_TOKEN);
            LogRequest("PrepareToTransact", "strSessionToken=" + strSessionToken);

            AppData = new ApplicationData();
            AppData.ApplicationAttended = false;
            AppData.ApplicationLocation = (ApplicationLocation) Enum.Parse(typeof (ApplicationLocation), "OffPremises");
            AppData.ApplicationName = "SoftwareName";
            AppData.DeveloperId = "";
            AppData.HardwareType = HardwareType.PC;
            AppData.PINCapability = (PINCapability) Enum.Parse(typeof (PINCapability), ipCommerceConfig.PIN_CAPABILITY);
            AppData.ReadCapability =
                (ReadCapability) Enum.Parse(typeof (ReadCapability), ipCommerceConfig.READ_CAPABILITY);
            AppData.SerialNumber = "123HA";
            AppData.SoftwareVersion = "2.5";
            AppData.SoftwareVersionDate = Convert.ToDateTime("2011-12-02");
            AppData.PTLSSocketId = ipCommerceConfig.PTLS_SOCKET_ID;

            strApplicationProfileID = CWSSIC.SaveApplicationData(strSessionToken, AppData);
            
            return result;
        }

        private BankcardTransactionResponse GetCreditCardTokenID(string pan, string expiry, int cctype)
        {
            LogRequest("GetCreditCardTokenID", "start");

            var result = new BankcardTransactionResponse();

            if (PrepareToTransact())
            {
                var BCTransaction = new BankcardTransaction();
                var BCResponse = new BankcardTransactionResponse();

//                BCTransaction = SetBankCardTxnData("5454545454545454", "0112", 4,"0.00", null);
//                BCResponse = (BankcardTransactionResponse)CWSTPC.AuthorizeAndCapture(strSessionToken, BCTransaction, strApplicationProfileID, strProfileID, strServiceID);
//                ProcessResponse(new ResponseDetails(BCTransaction.TransactionData.Amount, BCResponse,"AuthorizeAndCapture", true));
                BCTransaction = SetBankCardTxnData(pan, expiry, cctype, 0.00M, null, "123456");

                try
                {
                    BCResponse =
                        (BankcardTransactionResponse)
                        CWSTPC.AuthorizeAndCapture(strSessionToken, BCTransaction, strApplicationProfileID, strProfileID,
                                                   strServiceID);
                }
                catch (Exception ex)
                {
                }

                LogRequest("GetCreditCardTokenID", "status=" + BCResponse.Status +
                                                   " statusCode=" + BCResponse.StatusCode +
                                                   " statusMessage=" + BCResponse.StatusMessage + " amount=" +
                                                   BCResponse.Amount);

                result = BCResponse;
            }

            return result;
        }

        public static CWSServiceInformationClient GetServiceInfoChannel(string serviceActivationKey, string Uri)
        {
            lock (svcInfoChannelLock)
            {
                var client = new CWSServiceInformationClient();
                client.Endpoint.Address = new EndpointAddress(Uri + serviceActivationKey);
                client.Open();
                return client;
            }
        }

        public CwsTransactionProcessingClient GetChannel(string serviceActivationKey, string Uri)
        {
            lock (bankCardChannelLock)
            {
                var client = new CwsTransactionProcessingClient();
                client.Endpoint.Address = new EndpointAddress(Uri + serviceActivationKey);
                client.Open();
                return client;
            }
        }

        private BankcardTransactionPro SetBankCardTxnData(string pan, string expiry, int cctype, decimal amount,
                                                          string token, string transactionId)
        {
            var BCtransaction = new BankcardTransactionPro();
            var TxnData = new BankcardTransactionDataPro(); //The following is necessary due to inheritance            

            try
            {
                TxnData.EntryMode = (EntryMode) Enum.Parse(typeof (EntryMode), ipCommerceConfig.TXNDATA_ENTRY_MODE);
            }
            catch
            {
            }
            try
            {
                TxnData.IndustryType =
                    (IndustryType) Enum.Parse(typeof (IndustryType), ipCommerceConfig.TXNDATA_INDUSTRY_TYPE);
            }
            catch
            {
            }
            try
            {
                TxnData.CustomerPresent =
                    (CustomerPresent) Enum.Parse(typeof (CustomerPresent), ipCommerceConfig.TXNDATA_CUSTOMER_PRESENT);
            }
            catch
            {
            }
            try
            {
                TxnData.SignatureCaptured = Convert.ToBoolean(ipCommerceConfig.TXNDATA_SIGNATURE_CAPTURE);
            }
            catch
            {
            }

            TxnData.TransactionDateTime = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss.fffzzz");
            TxnData.EmployeeId = "123456"; //Used for Retail/Restaurant/MOTO
            TxnData.OrderNumber = transactionId;
                //"12354113"; //This values must be unique for each transaction. OrderNum should never be zero

            TxnData.TransactionDateTime = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss.fffzzz");

            BCtransaction.CustomerData = new TransactionCustomerData();
            BCtransaction.CustomerData.CustomerId = TxnData.OrderNumber;

            BCtransaction.TenderData = new BankcardTenderData();
            BCtransaction.TenderData.CardData = new CardData();

            // token transaction
            if (string.IsNullOrEmpty(token))
            {
                LogRequest("SetBankCardTxnData", "set data to get token");
                BCtransaction.TenderData.CardData.CardType = GetCardType(cctype);
                BCtransaction.TenderData.CardData.Expire = expiry;
                    // Note : that in a swipe track data the format is "YYMM" however here it's "MMYY"                    
                BCtransaction.TenderData.CardData.PAN = pan;
            }
                // payment transaction
            else
            {
                LogRequest("SetBankCardTxnData", "using transaction token=" + token);
                BCtransaction.TenderData.PaymentAccountDataToken = token;
                    //"c45bc692-a94e-4075-aa7b-7371f515b8c2dea7d1c5-0a84-4448-9dec-6912900b4c63"
            }

//            TxnData.Amount = Convert.ToDecimal(amount);
//            TxnData.Amount = Decimal.Parse(TxnData.Amount.ToString("0.00"));
            TxnData.Amount = amount;
            TxnData.Amount = Decimal.Parse(TxnData.Amount.ToString("0.00"));
            TxnData.CurrencyCode = TypeISOCurrencyCodeA3.USD;

            BCtransaction.TransactionData = TxnData;
            return BCtransaction;
        }

        private void ProcessResponse(ResponseDetails _Response)
        {
            if (_Response.Response is BankcardTransactionResponsePro)
            {
                //In the 1.17.11 release all response objects are BankcardTransactionResponsePro
                ProcessBankcardTransactionResponse(_Response);
            }
            //Future functionality as a BankcardTransactionResponse is presently not returned
            if (_Response.Response is BankcardTransactionResponse)
            {
            }
            if (_Response.Response is BankcardCaptureResponse)
            {
                //BankcardCaptureResponse
                ProcessBankcardCaptureResponse((BankcardCaptureResponse) _Response.Response, _Response.Verbose);
            }
        }

        private void ProcessBankcardTransactionResponse(ResponseDetails _Response)
        {
            var _BCResponse = new BankcardTransactionResponse();
            _BCResponse = (BankcardTransactionResponse) _Response.Response;
            //Note : IMPORTANT Always verify the approved amount was the same as the requested approval amount for "AuthorizeAndCapture" as well as "Authorize" 
            if (_Response.TransactionType == "AuthorizeAndCapture" | _Response.TransactionType == "Authorize")
            {
                if (_BCResponse.Amount != _Response.TxnAmount)
                {
//                    log.Debug("The transaction was approved for " + _BCResponse.Amount +
//                                               " which is an amount less than the requested amount of " +
//                                               _Response.TxnAmount +
//                                               ". Please provide alternate payment to complete transaction");
                }
            }

            if (!_Response.Verbose)
            {
                // In this case don't present to the user all of the data. 
                if (_BCResponse.Status == Status.Successful)
                {
                    //The transaction was approved
                    //NOTE : Please reference the developers guide for a more complete explination of the return fields
                    //Note Highly recommended to save
                    //The unique id of the transaction. TransactionId is required for all subsequent transactions such as Return, Undo, etc.
                    //Must be stored with the TransactionId in order to identify which merchant sent which transaction. Required to support multi-merchant.
                    //Note Optional but recommended to save
                    //Status code generated by the Service Provider. This code should be displayed to the user as verification of the transaction.
                    //Explains the StatusCode which is generated by the Service Provider. This message should be displayed to the user as verification of the transaction.
                    //A value returned when a transaction is approved. This value should be printed on the receipt, and also recorded for every off-line transaction, such as a voice authorization. This same data element and value must be provided during settlement. Required.
                    //Specifies the authorization amount of the transaction. This is the actual amount authorized.
//                    log.Debug(((((((("Your transaction type of " + _Response.TransactionType.ToString() +
//                                                     " was APPROVED" + "\r\n" +
//                                                     "TransactionId : ") + _BCResponse.TransactionId + "\r\n" + "MerchantProfileId : " + HID_strProfileID +
//                                                    "\r\n" + "Status Code : ") +
//                                                   _BCResponse.StatusCode.ToString() + "\r\n" +
//                                                   "Status Message : ") + _BCResponse.StatusMessage.ToString() +
//                                                  "\r\n" + "ApprovalCode : ") +
//                                                 _BCResponse.ApprovalCode.ToString() + "\r\n" +
//                                                 "Amount : ") + _BCResponse.Amount.ToString())));
                }
                if (_BCResponse.Status == Status.Failure)
                {
                    //The transaction was declined
                    //NOTE : Please reference the developers guide for a more complete explination of the return fields
                    //Note Highly recommended to save
                    //The unique id of the transaction. TransactionId is required for all subsequent transactions such as Return, Undo, etc.
                    //Must be stored with the TransactionId in order to identify which merchant sent which transaction. Required to support multi-merchant.
                    //Note Optional but recommended to save
                    //Status code generated by the Service Provider. This code should be displayed to the user as verification of the transaction.
                    //Explains the StatusCode which is generated by the Service Provider. This message should be displayed to the user as verification of the transaction.
//                    log.Debug(((("Your transaction type of " + _Response.TransactionType.ToString() +
//                                                  " was DECLINED" + "\r\n" + "TransactionId : ") +
//                                                 _BCResponse.TransactionId + "\r\n" +
//                                                 "MerchantProfileId : " + HID_strProfileID + "\r\n" + "Status Code : ") + _BCResponse.StatusCode +
//                                                "\r\n" + "Status Message : ") +
//                                               _BCResponse.StatusMessage);
                }
                return;
            }
            if (_BCResponse.Status == Status.Successful)
            {
                //The transaction was approved
                string strMessage = "";
                //NOTE : Please reference the developers guide for a more complete explination of the return fields
                strMessage = "Your transaction type of " + _Response.TransactionType + " was APPROVED";
                //Note Highly recommended to save
                strMessage = (strMessage + "\r\n" + "TransactionId : ") +
                             _BCResponse.TransactionId;
                //The unique id of the transaction. TransactionId is required for all subsequent transactions such as Return, Undo, etc.
                strMessage = strMessage + "\r\n" + "MerchantProfileId : " + strProfileID;
                //Must be stored with the TransactionId in order to identify which merchant sent which transaction. Required to support multi-merchant.
                //Note Highly recommended to save if Tokenization will be used
                //+  vbCrLf + "PaymentAccountDataToken : " + _BCResponse.PaymentAccountDataToken //If tokenization purchased this field represents the actual token returned in the transaction for future use.
                //Note Optional but recommended to save
                strMessage = (strMessage + "\r\n" + "Status Code : ") +
                             _BCResponse.StatusCode;
                //Status code generated by the Service Provider. This code should be displayed to the user as verification of the transaction.
                strMessage = (strMessage + "\r\n" + "Status Message : ") +
                             _BCResponse.StatusMessage;
                //Explains the StatusCode which is generated by the Service Provider. This message should be displayed to the user as verification of the transaction.
                strMessage = (strMessage + "\r\n" + "ApprovalCode : ") +
                             _BCResponse.ApprovalCode;
                //A value returned when a transaction is approved. This value should be printed on the receipt, and also recorded for every off-line transaction, such as a voice authorization. This same data element and value must be provided during settlement. Required.
                strMessage = (strMessage + "\r\n" + "Amount : ") + _BCResponse.Amount;
                //Specifies the authorization amount of the transaction. This is the actual amount authorized.
                //Note Optional but recommended if AVS is supported
                if (_BCResponse.AVSResult != null)
                {
                    strMessage = (strMessage + "\r\n" + "AVSResult ActualResult : ") +
                                 _BCResponse.AVSResult.ActualResult;
                    //Specifies the actual result of AVS from the Service Provider.
                    strMessage = (strMessage + "\r\n" + "AVSResult AddressResult : ") +
                                 _BCResponse.AVSResult.AddressResult;
                    //Specifies the result of AVS as it pertains to Address matching
                    //Specifies the result of AVS as it pertains to Postal Code matching
                    strMessage = (strMessage + "\r\n" + "AVSResult PostalCodeResult : ") +
                                 _BCResponse.AVSResult.PostalCodeResult;
                }
                //Note Optional but recommended if CV data is supported
                strMessage = (strMessage + "\r\n" + "CVResult : ") +
                             _BCResponse.CVResult;
                //Response code returned by the card issuer indicating the result of Card Verification (CVV2/CVC2/CID).
                //Note Optional
                strMessage = (strMessage + "\r\n" + "OrderId : ") +
                             _BCResponse.OrderId;
                //A unique ID used to identify a specific order.  This is used to process further transactions on Virtual Terminals.  
                strMessage = (strMessage + "\r\n" + "BatchId : ") +
                             _BCResponse.BatchId;
                //A unique ID used to identify a specific batch settlement                
                strMessage = (strMessage + "\r\n" + "DowngradeCode : ") +
                             _BCResponse.DowngradeCode;
                //Indicates downgrade reason.
                strMessage = (strMessage + "\r\n" + "FeeAmount : ") +
                             _BCResponse.FeeAmount;
                //Fee amount charged for the transaction. 
                strMessage = (strMessage + "\r\n" + "FinalBalance : ") +
                             _BCResponse.FinalBalance;
                //Fee amount charged for the transaction.
                strMessage = (strMessage + "\r\n" + "Resubmit : ") +
                             _BCResponse.Resubmit;
                //Specifies whether resubmission is supported for PIN Debit transactions.
                strMessage = (strMessage + "\r\n" + "ServiceTransactionId : ") +
                             _BCResponse.ServiceTransactionId;

                //+  vbCrLf + "SettlementDate : " + _BCResponse.SettlementDate //Settlement date. Conditional, if present in the authorization response, this same data element and value must be provided during settlement

                //Token generated
                strMessage = (strMessage + "\r\n" + "Token : ") +
                             _BCResponse.PaymentAccountDataToken;

//                log.Debug(strMessage);
            }
            if (_BCResponse.Status == Status.Failure)
            {
                //The transaction was declined
                //NOTE : Please reference the developers guide for a more complete explination of the return fields
                //Note Highly recommended to save
                //The unique id of the transaction. TransactionId is required for all subsequent transactions such as Return, Undo, etc.
                //Must be stored with the TransactionId in order to identify which merchant sent which transaction. Required to support multi-merchant.
                //Note Optional but recommended to save
                //Status code generated by the Service Provider. This code should be displayed to the user as verification of the transaction.
                //Explains the StatusCode which is generated by the Service Provider. This message should be displayed to the user as verification of the transaction.
                //Note Optional but recommended if CV data is supported
                //Response code returned by the card issuer indicating the result of Card Verification (CVV2/CVC2/CID).
                //Note Optional
//                log.Debug(((((("Your transaction type of " + _Response.TransactionType.ToString() +
//                                                " was DECLINED" + "\r\n" + "TransactionId : ") +
//                                               _BCResponse.TransactionId.ToString() + "\r\n" +
//                                               "MerchantProfileId : " + HID_strProfileID + "\r\n" + "Status Code : ") + _BCResponse.StatusCode.ToString() +
//                                              "\r\n" + "Status Message : ") +
//                                             _BCResponse.StatusMessage.ToString() + "\r\n" +
//                                             "CVResult : ") + _BCResponse.CVResult.ToString() + "\r\n" + "ServiceTransactionId : ") +
//                                           _BCResponse.ServiceTransactionId.ToString());
            }
        }

        private void ProcessBankcardCaptureResponse(BankcardCaptureResponse _BCResponse, bool _blnVerbose)
        {
            string strResponseMessage = "";

            if (!_blnVerbose)
            {
                // In this case don't present to the user all of the data. 
                if (_BCResponse.Status == Status.Successful)
                {
                    //The transaction was approved
                    //NOTE : Please reference the developers guide for a more complete explination of the return fields
                    //Note Highly recommended to save
                    if (_BCResponse.TransactionId != null)
                    {
                        strResponseMessage = strResponseMessage + "\r\n" + "TransactionId : " +
                                             Convert.ToString(_BCResponse.TransactionId);
                    }
                    strResponseMessage = strResponseMessage + "\r\n" + "Merchant Profile Id : " +
                                         strProfileID;
                    //Note Optional but recommended to save
                    if (_BCResponse.StatusCode != null)
                    {
                        strResponseMessage = strResponseMessage + "\r\n" + "Status Code : " +
                                             Convert.ToString(_BCResponse.StatusCode);
                    }
                    if (_BCResponse.StatusMessage != null)
                    {
                        strResponseMessage = strResponseMessage + "\r\n" + "Status Message : " +
                                             Convert.ToString(_BCResponse.StatusMessage);
                    }

//                    log.Debug("Your transaction was APPROVED" + "\r\n" +
//                                               strResponseMessage);
                }
                if (_BCResponse.Status == Status.Failure)
                {
                    //The transaction was declined
                    //NOTE : Please reference the developers guide for a more complete explination of the return fields
                    //Note Highly recommended to save
                    if (_BCResponse.TransactionId != null)
                    {
                        strResponseMessage = strResponseMessage + "\r\n" + "TransactionId : " +
                                             Convert.ToString(_BCResponse.TransactionId);
                    }
                    strResponseMessage = strResponseMessage + "\r\n" + "Merchant Profile Id : " +
                                         strProfileID;
                    //Note Optional but recommended to save
                    if (_BCResponse.StatusCode != null)
                    {
                        strResponseMessage = strResponseMessage + "\r\n" + "Status Code : " +
                                             Convert.ToString(_BCResponse.StatusCode);
                    }
                    if (_BCResponse.StatusMessage != null)
                    {
                        strResponseMessage = strResponseMessage + "\r\n" + "Status Message : " +
                                             Convert.ToString(_BCResponse.StatusMessage);
                    }

//                    log.Debug("Your transaction was DECLINED" + "\r\n" +
//                                               strResponseMessage);
                }
                return;
            }
            if (_BCResponse.Status == Status.Successful)
            {
                //The transaction was approved
                //NOTE : Please reference the developers guide for a more complete explination of the return fields
                //Note Highly recommended to save
                if (_BCResponse.TransactionId != null)
                {
                    strResponseMessage = strResponseMessage + "\r\n" + "TransactionId : " +
                                         Convert.ToString(_BCResponse.TransactionId);
                }
                strResponseMessage = strResponseMessage + "\r\n" + "Merchant Profile Id : " +
                                     strProfileID;
                //Note Optional but recommended to save
                if (_BCResponse.StatusCode != null)
                {
                    strResponseMessage = strResponseMessage + "\r\n" + "Status Code : " +
                                         Convert.ToString(_BCResponse.StatusCode);
                }
                if (_BCResponse.StatusMessage != null)
                {
                    strResponseMessage = strResponseMessage + "\r\n" + "Status Message : " +
                                         Convert.ToString(_BCResponse.StatusMessage);
                }
                //Note Optional data about the batch
                if (_BCResponse.BatchId != null)
                {
                    strResponseMessage = strResponseMessage + "\r\n" + "Batch Id : " +
                                         Convert.ToString(_BCResponse.BatchId);
                }
                if (_BCResponse.TransactionSummaryData != null)
                {
                    if (_BCResponse.TransactionSummaryData.CashBackTotals != null)
                    {
                        strResponseMessage = strResponseMessage + "\r\n" + "Cash Back Totals " +
                                             "\r\n" + "  Count : " +
                                             Convert.ToString(_BCResponse.TransactionSummaryData.CashBackTotals.Count) +
                                             "\r\n" + "  Net Amount : " +
                                             Convert.ToString(
                                                 _BCResponse.TransactionSummaryData.CashBackTotals.NetAmount.ToString());
                    }
                    if (_BCResponse.TransactionSummaryData.NetTotals != null)
                    {
                        strResponseMessage = strResponseMessage + "\r\n" + "Net Totals " +
                                             "\r\n" + "  Count : " +
                                             Convert.ToString(_BCResponse.TransactionSummaryData.NetTotals.Count) +
                                             "\r\n" + "  Net Amount : " +
                                             Convert.ToString(
                                                 _BCResponse.TransactionSummaryData.NetTotals.NetAmount.ToString());
                    }
                    if (_BCResponse.TransactionSummaryData.PINDebitReturnTotals != null)
                    {
                        strResponseMessage = strResponseMessage + "\r\n" +
                                             "PINDebit Return Totals " + "\r\n" + "  Count : " +
                                             Convert.ToString(
                                                 _BCResponse.TransactionSummaryData.PINDebitReturnTotals.Count) +
                                             "\r\n" + "  Net Amount : " +
                                             Convert.ToString(
                                                 _BCResponse.TransactionSummaryData.PINDebitReturnTotals.NetAmount.
                                                     ToString());
                    }
                    if (_BCResponse.TransactionSummaryData.PINDebitSaleTotals != null)
                    {
                        strResponseMessage = strResponseMessage + "\r\n" + "PINDebit Sale Totals " +
                                             "\r\n" + "  Count : " +
                                             Convert.ToString(
                                                 _BCResponse.TransactionSummaryData.PINDebitSaleTotals.Count) +
                                             "\r\n" + "  Net Amount : " +
                                             Convert.ToString(
                                                 _BCResponse.TransactionSummaryData.PINDebitSaleTotals.NetAmount.
                                                     ToString());
                    }
                    if (_BCResponse.TransactionSummaryData.ReturnTotals != null)
                    {
                        strResponseMessage = strResponseMessage + "\r\n" + "Return Totals " +
                                             "\r\n" + "  Count : " +
                                             Convert.ToString(_BCResponse.TransactionSummaryData.ReturnTotals.Count) +
                                             "\r\n" + "  Net Amount : " +
                                             Convert.ToString(
                                                 _BCResponse.TransactionSummaryData.ReturnTotals.NetAmount.ToString());
                    }
                    if (_BCResponse.TransactionSummaryData.SaleTotals != null)
                    {
                        strResponseMessage = strResponseMessage + "\r\n" + "Sale Totals " +
                                             "\r\n" + "  Count : " +
                                             Convert.ToString(_BCResponse.TransactionSummaryData.SaleTotals.Count) +
                                             "\r\n" + "  Net Amount : " +
                                             Convert.ToString(
                                                 _BCResponse.TransactionSummaryData.SaleTotals.NetAmount.ToString());
                    }
                    if (_BCResponse.TransactionSummaryData.VoidTotals != null)
                    {
                        strResponseMessage = strResponseMessage + "\r\n" + "Void Totals " +
                                             "\r\n" + "  Count : " +
                                             Convert.ToString(_BCResponse.TransactionSummaryData.VoidTotals.Count) +
                                             "\r\n" + "  Net Amount : " +
                                             Convert.ToString(
                                                 _BCResponse.TransactionSummaryData.VoidTotals.NetAmount.ToString());
                    }
                }

//                log.Debug("Your transaction was APPROVED" + "\r\n" +
//                                           strResponseMessage);
            }
            if (_BCResponse.Status == Status.Failure)
            {
                //The transaction was declined
                //NOTE : Please reference the developers guide for a more complete explination of the return fields
                //Note Highly recommended to save
                if (_BCResponse.TransactionId != null)
                {
                    strResponseMessage = strResponseMessage + "\r\n" + "TransactionId : " +
                                         Convert.ToString(_BCResponse.TransactionId);
                }
                strResponseMessage = strResponseMessage + "\r\n" + "Merchant Profile Id : " +
                                     strProfileID;
                //Note Optional but recommended to save
                if (_BCResponse.StatusCode != null)
                {
                    strResponseMessage = strResponseMessage + "\r\n" + "Status Code : " +
                                         Convert.ToString(_BCResponse.StatusCode);
                }
                if (_BCResponse.StatusMessage != null)
                {
                    strResponseMessage = strResponseMessage + "\r\n" + "Status Message : " +
                                         Convert.ToString(_BCResponse.StatusMessage);
                }
                //Note Optional

//                log.Error("Your transaction was DECLINED" + "\r\n" +
//                                           strResponseMessage);
            }
            if (_BCResponse.Status == Status.NotSet)
            {
                //The transaction was declined
            }
        }

        private TypeCardType GetCardType(int cctype)
        {
            TypeCardType result = TypeCardType.NotSet;

            switch (cctype)
            {
                case (int) CreditCardTypeEnum.Solo:
                    break;

                case (int) CreditCardTypeEnum.Maestro:
                    break;

                case (int) CreditCardTypeEnum.VisaDebit:
                    break;

                case (int) CreditCardTypeEnum.VisaElectron:
                    break;

                case (int) CreditCardTypeEnum.VisaCredit:
                    result = TypeCardType.Visa;
                    break;

                case (int) CreditCardTypeEnum.MasterCard:
                    result = TypeCardType.MasterCard;
                    break;

                case (int) CreditCardTypeEnum.AmericanExpress:
                    result = TypeCardType.AmericanExpress;
                    break;

                case (int) CreditCardTypeEnum.Diners:
                    result = TypeCardType.DinersCartBlanche;
                    break;

                case (int) CreditCardTypeEnum.JCB:
                    result = TypeCardType.JCB;
                    break;

                default:
                    break;
            }

            LogRequest("GetCardType", "cctype=" + cctype + " result=" + result);
            return result;
        }

        #region Nested type: ResponseDetails

        public class ResponseDetails
        {
            public Response Response;
            public string TransactionType;
            public decimal TxnAmount;

            public bool Verbose;

            public ResponseDetails(decimal txnAmount__1, Response response__2, string transactionType__3,
                                   bool verbose__4)
            {
                TxnAmount = txnAmount__1;
                Response = response__2;
                TransactionType = transactionType__3;
                Verbose = verbose__4;
            }
        }

        #endregion
    }
}