
# Delete existing artifacts
rm genesis.block bank-channel.tx
rm -rf ../../channel-artifacts/*

#Generate Crypto artifactes for organizations
# cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/



# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "bank-channel"
CHANNEL_NAME="bank-channel"

echo $CHANNEL_NAME

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./genesis.block


# Generate channel configuration block
configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./bank-channel.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for UBSMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./UBSMSPanchors.tx -channelID $CHANNEL_NAME -asOrg UBSMSP

echo "#######    Generating anchor peer update for CITIMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./CITIMSPanchors.tx -channelID $CHANNEL_NAME -asOrg CITIMSP

echo "#######    Generating anchor peer update for DBSMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./DBSMSPanchors.tx -channelID $CHANNEL_NAME -asOrg DBSMSP