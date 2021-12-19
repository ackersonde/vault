# recovery-shares stuff is Auto Unseal ops
vault operator init -recovery-shares=5 -recovery-threshold=3 > generated_keys.txt
export keyArray=$(grep 'Unseal Key ' < generated_keys.txt  | cut -c15-)
for s in $keyArray; do
  vault operator unseal "$s"
done
unset keyArray
export VAULT_TOKEN=$(grep "Initial Root Token: " < generated_keys.txt  | cut -c21-)

# Enable kv
vault secrets enable -version=1 kv

# Enable userpass and add default user
vault auth enable userpass
vault policy write spring-policy spring-policy.hcl
vault write auth/userpass/users/admin password=${SECRET_PASS} policies=spring-policy

# Add test value to my-secret
vault kv put kv/my-secret my-value=s3cr3t

# For bender daily cron:
docker exec -it vault ash -c "VAULT_TOKEN=${VAULT_TOKEN} vault operator raft snapshot save backup.snap"