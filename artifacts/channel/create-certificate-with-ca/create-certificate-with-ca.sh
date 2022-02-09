createcertificatesForUBS() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/peerOrganizations/UBS.bank.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca.UBS.bank.com --tls.certfiles ${PWD}/fabric-ca/UBS/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-UBS-bank-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-UBS-bank-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-UBS-bank-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-UBS-bank-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
  fabric-ca-client register --caname ca.UBS.bank.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/UBS/tls-cert.pem

  echo
  echo "Register user"
  echo
  fabric-ca-client register --caname ca.UBS.bank.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/UBS/tls-cert.pem

  echo
  echo "Register the org admin"
  echo
  fabric-ca-client register --caname ca.UBS.bank.com --id.name UBSadmin --id.secret UBSadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/UBS/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/UBS.bank.com/peers

  # -----------------------------------------------------------------------------------
  #  Peer 0
  mkdir -p ../crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com

  echo
  echo "## Generate the peer0 msp"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.UBS.bank.com -M ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/msp --csr.hosts peer0.UBS.bank.com --tls.certfiles ${PWD}/fabric-ca/UBS/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.UBS.bank.com -M ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/tls --enrollment.profile tls --csr.hosts peer0.UBS.bank.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/UBS/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/tlsca/tlsca.UBS.bank.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/peers/peer0.UBS.bank.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/ca/ca.UBS.bank.com-cert.pem

  # --------------------------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/UBS.bank.com/users
  mkdir -p ../crypto-config/peerOrganizations/UBS.bank.com/users/User1@UBS.bank.com

  echo
  echo "## Generate the user msp"
  echo
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca.UBS.bank.com -M ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/users/User1@UBS.bank.com/msp --tls.certfiles ${PWD}/fabric-ca/UBS/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/UBS.bank.com/users/Admin@UBS.bank.com

  echo
  echo "## Generate the org admin msp"
  echo
  fabric-ca-client enroll -u https://UBSadmin:UBSadminpw@localhost:7054 --caname ca.UBS.bank.com -M ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/users/Admin@UBS.bank.com/msp --tls.certfiles ${PWD}/fabric-ca/UBS/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/UBS.bank.com/users/Admin@UBS.bank.com/msp/config.yaml

}

# createcertificatesForUBS

createCertificatesForCITI() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p /../crypto-config/peerOrganizations/CITI.bank.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca.CITI.bank.com --tls.certfiles ${PWD}/fabric-ca/CITI/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-CITI-bank-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-CITI-bank-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-CITI-bank-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-CITI-bank-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.CITI.bank.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/CITI/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.CITI.bank.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/CITI/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.CITI.bank.com --id.name CITIadmin --id.secret CITIadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/CITI/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/CITI.bank.com/peers
  mkdir -p ../crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.CITI.bank.com -M ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/msp --csr.hosts peer0.CITI.bank.com --tls.certfiles ${PWD}/fabric-ca/CITI/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.CITI.bank.com -M ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/tls --enrollment.profile tls --csr.hosts peer0.CITI.bank.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/CITI/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/tlsca/tlsca.CITI.bank.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/peers/peer0.CITI.bank.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/ca/ca.CITI.bank.com-cert.pem

  # --------------------------------------------------------------------------------
 
  mkdir -p ../crypto-config/peerOrganizations/CITI.bank.com/users
  mkdir -p ../crypto-config/peerOrganizations/CITI.bank.com/users/User1@CITI.bank.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca.CITI.bank.com -M ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/users/User1@CITI.bank.com/msp --tls.certfiles ${PWD}/fabric-ca/CITI/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/CITI.bank.com/users/Admin@CITI.bank.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://CITIadmin:CITIadminpw@localhost:8054 --caname ca.CITI.bank.com -M ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/users/Admin@CITI.bank.com/msp --tls.certfiles ${PWD}/fabric-ca/CITI/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/CITI.bank.com/users/Admin@CITI.bank.com/msp/config.yaml

}

# createCertificateForCITI

createCertificatesForDBS() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p /../crypto-config/peerOrganizations/DBS.bank.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca.DBS.bank.com --tls.certfiles ${PWD}/fabric-ca/DBS/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-DBS-bank-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-DBS-bank-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-DBS-bank-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-DBS-bank-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.DBS.bank.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/DBS/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.DBS.bank.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/DBS/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.DBS.bank.com --id.name DBSadmin --id.secret DBSadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/DBS/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/DBS.bank.com/peers
  mkdir -p ../crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca.DBS.bank.com -M ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/msp --csr.hosts peer0.DBS.bank.com --tls.certfiles ${PWD}/fabric-ca/DBS/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca.DBS.bank.com -M ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/tls --enrollment.profile tls --csr.hosts peer0.DBS.bank.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/DBS/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/tlsca/tlsca.DBS.bank.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/peers/peer0.DBS.bank.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/ca/ca.DBS.bank.com-cert.pem

  # --------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/DBS.bank.com/users
  mkdir -p ../crypto-config/peerOrganizations/DBS.bank.com/users/User1@DBS.bank.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:10054 --caname ca.DBS.bank.com -M ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/users/User1@DBS.bank.com/msp --tls.certfiles ${PWD}/fabric-ca/DBS/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/DBS.bank.com/users/Admin@DBS.bank.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://DBSadmin:DBSadminpw@localhost:10054 --caname ca.DBS.bank.com -M ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/users/Admin@DBS.bank.com/msp --tls.certfiles ${PWD}/fabric-ca/DBS/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/DBS.bank.com/users/Admin@DBS.bank.com/msp/config.yaml

}

createCretificatesForOrderer() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/ordererOrganizations/bank.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/ordererOrganizations/bank.com

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/ordererOrganizations/bank.com/msp/config.yaml

  echo
  echo "Register orderer"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer2"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer3"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register the orderer admin"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  mkdir -p ../crypto-config/ordererOrganizations/bank.com/orderers
  # mkdir -p ../crypto-config/ordererOrganizations/bank.com/orderers/bank.com

  # ---------------------------------------------------------------------------
  #  Orderer

  mkdir -p ../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/msp --csr.hosts orderer.bank.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/tls --enrollment.profile tls --csr.hosts orderer.bank.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/tls/ca.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/tls/server.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/tls/server.key

  mkdir ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/msp/tlscacerts/tlsca.bank.com-cert.pem

  mkdir ${PWD}/../crypto-config/ordererOrganizations/bank.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/msp/tlscacerts/tlsca.bank.com-cert.pem

  # -----------------------------------------------------------------------
  #  Orderer 2

  mkdir -p ../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com/msp --csr.hosts orderer2.bank.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com/tls --enrollment.profile tls --csr.hosts orderer2.bank.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com/tls/ca.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com/tls/server.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com/tls/server.key

  mkdir ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com/msp/tlscacerts/tlsca.bank.com-cert.pem

  # mkdir ${PWD}/../crypto-config/ordererOrganizations/bank.com/msp/tlscacerts
  # cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer2.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/msp/tlscacerts/tlsca.bank.com-cert.pem

  # ---------------------------------------------------------------------------
  #  Orderer 3
  mkdir -p ../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com/msp --csr.hosts orderer3.bank.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com/tls --enrollment.profile tls --csr.hosts orderer3.bank.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com/tls/ca.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com/tls/server.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com/tls/server.key

  mkdir ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com/msp/tlscacerts/tlsca.bank.com-cert.pem

  # mkdir ${PWD}/../crypto-config/ordererOrganizations/bank.com/msp/tlscacerts
  # cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/orderers/orderer3.bank.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/bank.com/msp/tlscacerts/tlsca.bank.com-cert.pem

  # ---------------------------------------------------------------------------

  mkdir -p ../crypto-config/ordererOrganizations/bank.com/users
  mkdir -p ../crypto-config/ordererOrganizations/bank.com/users/Admin@bank.com

  echo
  echo "## Generate the admin msp"
  echo
   
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/bank.com/users/Admin@bank.com/msp --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/bank.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/bank.com/users/Admin@bank.com/msp/config.yaml

}

# createCretificateForOrderer

sudo rm -rf ../crypto-config/*
# sudo rm -rf fabric-ca/*
createcertificatesForUBS
createCertificatesForCITI
createCertificatesForDBS

createCretificatesForOrderer

