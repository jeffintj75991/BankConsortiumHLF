export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/msp/tlscacerts/tlsca.bank.com-cert.pem
export PEER0_UBS_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/tls/ca.crt
export PEER0_CITI_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/tls/ca.crt
export PEER0_DBS_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=bank-channel

setGlobalsForPeer0UBS(){
    export CORE_PEER_LOCALMSPID="UBSMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_UBS_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/UBS.bank.com/users/Admin@UBS.bank.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0CITI(){
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

createChannel(){
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0UBS
    
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.bank.com \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

removeOldCrypto(){
    rm -rf ./api-1.4/crypto/*
    rm -rf ./api-1.4/fabric-client-kv-UBS/*
    rm -rf ./api-2.0/UBS-wallet/*
    rm -rf ./api-2.0/CITI-wallet/*
}


joinChannel(){
    setGlobalsForPeer0UBS
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    
    setGlobalsForPeer0CITI
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer0DBS
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
}

updateAnchorPeers(){
    setGlobalsForPeer0UBS
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.bank.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0CITI
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.bank.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

    setGlobalsForPeer0DBS
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.bank.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
}

removeOldCrypto

createChannel
joinChannel
updateAnchorPeers