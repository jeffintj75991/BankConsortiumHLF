/*
Copyright 2021 IBM All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

const (
	mspID         = "UBSMSP"
	cryptoPath    = "../artifacts/channel/crypto-config/peerOrganizations/UBS.bank.com"
	certPath      = cryptoPath + "/users/User1@UBS.bank.com/msp/signcerts/cert.pem"
	keyPath       = cryptoPath + "/users/User1@UBS.bank.com/msp/keystore/"
	tlsCertPath   = cryptoPath + "/peers/peer0.UBS.bank.com/tls/ca.crt"
	peerEndpoint  = "localhost:7051"
	gatewayPeer   = "peer0.UBS.bank.com"
	channelName   = "bank-channel"
	chaincodeName = "banktrxn"
)

func main() {
	log.Println("============ application-golang starts ============")

	// The gRPC client connection should be shared by all Gateway connections to this endpoint

	router := mux.NewRouter().StrictSlash(true)

	router.HandleFunc("/createBank", createBankTrxnsCall).Methods("POST")
	router.HandleFunc("/getBankTxnById", getBankTxnByIdCall).Methods("POST")
	log.Fatal(http.ListenAndServe(":8082", router))

}
