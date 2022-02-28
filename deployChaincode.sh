export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/msp/tlscacerts/tlsca.bank.com-cert.pem
export PEER0_UBS_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/tls/ca.crt
export PEER0_CITI_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/tls/ca.crt
export PEER0_DBS_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=bank-channel

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/msp/tlscacerts/tlsca.bank.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/bank.com/users/Admin@bank.com/msp

}

setGlobalsForPeer0UBS() {
    export CORE_PEER_LOCALMSPID="UBSMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_UBS_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/UBS.bank.com/users/Admin@UBS.bank.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForUBS() {
    export CORE_PEER_LOCALMSPID="UBSMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_UBS_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/UBS.bank.com/users/User1@UBS.bank.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0CITI() {
    export CORE_PEER_LOCALMSPID="CITIMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CITI_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/CITI.bank.com/users/Admin@CITI.bank.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

}

setGlobalsForPeer0DBS(){
    export CORE_PEER_LOCALMSPID="DBSMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DBS_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/DBS.bank.com/users/Admin@DBS.bank.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
    
}

presetup() {
    echo Vendoring Go dependencies ...
    pushd ./artifacts/src/github.com/banktrxn/go
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}
# presetup

CHANNEL_NAME="bank-channel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
SEQUENCE="1"
CC_SRC_PATH="./artifacts/src/github.com/banktrxn/go"
CC_NAME="banktrxn"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0UBS
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "
}
# packageChaincode

installChaincode() {
    setGlobalsForPeer0UBS
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.UBS ===================== "

    setGlobalsForPeer0CITI
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.CITI ===================== "

    setGlobalsForPeer0DBS
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.DBS ===================== "
}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0UBS
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.UBS on channel ===================== "
}

# queryInstalled

# --collections-config ./artifacts/private-data/collections_config.json \
#         --signature-policy "OR('UBSMSP.member','CITIMSP.member')" \

approveForMyUBS() {
    setGlobalsForPeer0UBS
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.bank.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}
# queryInstalled
# approveForMyUBS

# --signature-policy "OR ('UBSMSP.member')"
# --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_UBS_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CITI_CA
# --peerAddresses peer0.UBS.bank.com:7051 --tlsRootCertFiles $PEER0_UBS_CA --peerAddresses peer0.CITI.bank.com:9051 --tlsRootCertFiles $PEER0_CITI_CA
#--channel-config-policy Channel/Application/Admins
# --signature-policy "OR ('UBSMSP.peer','CITIMSP.peer')"

checkCommitReadyness() {
    setGlobalsForPeer0UBS
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

approveForMyCITI() {
    setGlobalsForPeer0CITI

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.bank.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}

    echo "===================== chaincode approved from org 2 ===================== "
}

# queryInstalled
# approveForMyCITI

checkCommitReadyness() {

    setGlobalsForPeer0CITI
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CITI_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

approveForMyDBS() {
    setGlobalsForPeer0DBS

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.bank.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}

    echo "===================== chaincode approved from org 2 ===================== "
}

# queryInstalled
# approveForMyDBS

checkCommitReadyness() {

    setGlobalsForPeer0DBS
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_DBS_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0UBS
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.bank.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_UBS_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CITI_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_DBS_CA \
        --version ${VERSION} --sequence ${SEQUENCE} --init-required

}

# commitChaincodeDefination

queryCommitted() {
    setGlobalsForPeer0UBS
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted

chaincodeInvokeInit() {
    setGlobalsForPeer0UBS
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.bank.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_UBS_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CITI_CA \
         --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_DBS_CA \
        --isInit -c '{"Args":[]}'

}

# chaincodeInvokeInit

chaincodeInvoke() {
    setGlobalsForPeer0UBS

    # Create Car
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.bank.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_UBS_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CITI_CA   \
        -c '{"function": "CreateBankTrxns","Args":["{\"transactionId\":\"TXN00000001\",\"country\":\"India\",\"currency\":\"Rupees\",\"amount\":\"200000\", \"origin\":\"US\",\"date\":\"29-09-2021\"}"]}'

}

# chaincodeInvoke

chaincodeQuery() {
    setGlobalsForPeer0UBS
    # setGlobalsForUBS
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "GetBankById","Args":["TXN00000001"]}'
}

# chaincodeQuery

# Run this function if you add any new dependency in chaincode
presetup

packageChaincode
installChaincode
queryInstalled
approveForMyUBS
checkCommitReadyness
approveForMyCITI
checkCommitReadyness
approveForMyDBS
checkCommitReadyness
commitChaincodeDefination
queryCommitted
chaincodeInvokeInit
sleep 5
chaincodeInvoke
sleep 3
chaincodeQuery
