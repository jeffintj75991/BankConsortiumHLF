Peer version should be 2.4 or greater to run gateway service in Go SDK

Start by

go run .

For submitting the transaction:

url:  localhost:8082/createBank

body: {"transactionId":"TXN00000003","country":"Indonesia","currency":"Rupiah","amount":"200000", "origin":"US","date":"29-09-2021"}


for querying:

url:localhost:8082/getBankTxnById

body: TXN00000003
