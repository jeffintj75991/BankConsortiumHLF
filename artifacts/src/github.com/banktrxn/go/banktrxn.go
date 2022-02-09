package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/hyperledger/fabric/common/flogging"
)

type SmartContract struct {
	contractapi.Contract
}

var logger = flogging.MustGetLogger("banktrxn_cc")

type BankTrxns struct {
	TransactionId      string `json:"transactionId"`
	Country    string `json:"country"`
	Currency   string `json:"currency"`
	Amount   string `json:"amount"`
	Origin   string `json:"origin"`
	Date string `json:"date"`
}

func (s *SmartContract) CreateBankTrxns(ctx contractapi.TransactionContextInterface, bankData string) (string, error) {

	if len(bankData) == 0 {
		return "", fmt.Errorf("Please pass the correct Bank transaction data")
	}

	var bankTrxns BankTrxns
	err := json.Unmarshal([]byte(bankData), &bankTrxns)
	if err != nil {
		return "", fmt.Errorf("Failed while unmarshling Bank. %s", err.Error())
	}

	BankAsBytes, err := json.Marshal(bankTrxns)
	if err != nil {
		return "", fmt.Errorf("Failed while marshling Bank. %s", err.Error())
	}

	ctx.GetStub().SetEvent("CreateAsset", BankAsBytes)

	return ctx.GetStub().GetTxID(), ctx.GetStub().PutState(bankTrxns.TransactionId, BankAsBytes)
}

//
func (s *SmartContract) UpdateBankTrxDtls(ctx contractapi.TransactionContextInterface, TransactionId string, newOrigin string) (string, error) {

	if len(TransactionId) == 0 {
		return "", fmt.Errorf("Please pass the correct Bank id")
	}

	BankDtlsAsBytes, err := ctx.GetStub().GetState(TransactionId)

	if err != nil {
		return "", fmt.Errorf("Failed to get Bank data. %s", err.Error())
	}

	if BankDtlsAsBytes == nil {
		return "", fmt.Errorf("%s does not exist", TransactionId)
	}

	BankDtls := new(BankTrxns)
	_ = json.Unmarshal(BankDtlsAsBytes, BankDtls)

	BankDtls.Origin = newOrigin

	BankDtlsAsBytes, err = json.Marshal(BankDtls)
	if err != nil {
		return "", fmt.Errorf("Failed while marshling Bank. %s", err.Error())
	}

	//  txId := ctx.GetStub().GetTxID()

	return ctx.GetStub().GetTxID(), ctx.GetStub().PutState(BankDtls.TransactionId, BankDtlsAsBytes)

}

func (s *SmartContract) GetHistoryForAsset(ctx contractapi.TransactionContextInterface, TransactionId string) (string, error) {

	resultsIterator, err := ctx.GetStub().GetHistoryForKey(TransactionId)
	if err != nil {
		return "", fmt.Errorf(err.Error())
	}
	defer resultsIterator.Close()

	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return "", fmt.Errorf(err.Error())
		}
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	return string(buffer.Bytes()), nil
}

func (s *SmartContract) GetBankTxnById(ctx contractapi.TransactionContextInterface, TransactionId string) (*BankTrxns, error) {
	if len(TransactionId) == 0 {
		return nil, fmt.Errorf("Please provide correct contract Id")
		// return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	BankDtlsAsBytes, err := ctx.GetStub().GetState(TransactionId)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if BankDtlsAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", TransactionId)
	}

	BankDtls := new(BankTrxns)
	_ = json.Unmarshal(BankDtlsAsBytes, BankDtls)

	return BankDtls, nil

}

func (s *SmartContract) DeleteBankById(ctx contractapi.TransactionContextInterface, TransactionId string) (string, error) {
	if len(TransactionId) == 0 {
		return "", fmt.Errorf("Please provide correct contract Id")
	}

	return ctx.GetStub().GetTxID(), ctx.GetStub().DelState(TransactionId)
}

func (s *SmartContract) GetContractsForQuery(ctx contractapi.TransactionContextInterface, queryString string) ([]BankTrxns, error) {

	queryResults, err := s.getQueryResultForQueryString(ctx, queryString)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from ----world state. %s", err.Error())
	}

	return queryResults, nil

}

func (s *SmartContract) getQueryResultForQueryString(ctx contractapi.TransactionContextInterface, queryString string) ([]BankTrxns, error) {

	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []BankTrxns{}

	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		newBank := new(BankTrxns)

		err = json.Unmarshal(response.Value, newBank)
		if err != nil {
			return nil, err
		}

		results = append(results, *newBank)
	}
	return results, nil
}

func (s *SmartContract) GetDocumentUsingBankContract(ctx contractapi.TransactionContextInterface, documentID string) (string, error) {
	if len(documentID) == 0 {
		return "", fmt.Errorf("Please provide correct contract Id")
	}

	params := []string{"GetDocumentById", documentID}
	queryArgs := make([][]byte, len(params))
	for i, arg := range params {
		queryArgs[i] = []byte(arg)
	}

	response := ctx.GetStub().InvokeChaincode("document_cc", queryArgs, "bank-channel")

	return string(response.Payload), nil

}

func (s *SmartContract) GetBankdtlsFromKyc(ctx contractapi.TransactionContextInterface, transactionID string) (string, error) {
	if len(transactionID) == 0 {
		return "", fmt.Errorf("Please provide correct contract Id")
	}

	params := []string{"GetBankTxnById", transactionID}
	queryArgs := make([][]byte, len(params))
	for i, arg := range params {
		queryArgs[i] = []byte(arg)
	}

	response := ctx.GetStub().InvokeChaincode("banktrxn", queryArgs, "kyc-channel")

	return string(response.Payload), nil

}

func (s *SmartContract) CreateDocumentUsingBankContract(ctx contractapi.TransactionContextInterface, functionName string, documentData string) (string, error) {
	if len(documentData) == 0 {
		return "", fmt.Errorf("Please provide correct document data")
	}

	params := []string{functionName, documentData}
	queryArgs := make([][]byte, len(params))
	for i, arg := range params {
		queryArgs[i] = []byte(arg)
	}

	response := ctx.GetStub().InvokeChaincode("document_cc", queryArgs, "bank-channel")

	return string(response.Payload), nil

}

func main() {

	chaincode, err := contractapi.NewChaincode(new(SmartContract))
	if err != nil {
		fmt.Printf("Error create banktrxn chaincode: %s", err.Error())
		return
	}
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting chaincodes: %s", err.Error())
	}

}
