useradd -m -g operaciones ansible
mkdir -p /home/ansible/.ssh/
touch /home/ansible/.ssh/authorized_keys
chmod 700 /home/ansible/.ssh/
chmod 600 /home/ansible/.ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVF/9ppprufSGZKnvsVXMy7rolCRnDDs57nv6DIlxF3sGSn1NXpxSf6oUOVGL97XEYnjnVg3Qq/IzFpqWXupdpyM+cCTdq5yZ44X//FUCwLDy/JptbL55x+df/r6s2k/RrqL6672QVxoMF7BGXgfwYJojJXlAtqGQIkurcGrkoftXR480PdNyy+FWq2gCsim9P2npnMaDGCPWIt9oN9tAO8Amx7Uh0fion549d5zG3EfTSCjG3ZfcgqEEYz2dF0/iVCXjw/r5DRFp1v45C/kZuRiTSK5EPmxB2RKLIWSJs2QiLcl1WK+tWcdbeENNPlLZxA0JtqQ/aTwO6ac50phTFI7kWHQ5XvEBSt3K8znWEdb0S0p+RmCdB0KiU2SIfN3QQ3slswd5OYzgHpgNkZkBzYFbzhZXHEYbnuFGalYpEFuGaFR/dE59IslWUckPVqkYfR50Xz/hF2+5GtnaOhPfxYp4mPAWdSes9nhTkdgKS899s4LWObf8zkn8EvmhA0/SYg1T/sfznxsPlCrO9yUoE8SkPwWh2900AVsRU5LRu4aQIo0HbJoA9NGHg26PBVEEn+cpV9Pduxy4gt7OOqmRkC4/Kit+qrJPQFqJvjVSMpi4NiuDqzMMq2tYsR0ABVpg3MG6Cb1HIf7s/rhy7LsOLv4sbs34hX43ntM4PEk/cnQ== ansible@jvpu0srvs01-1' > /home/ansible/.ssh/authorized_keys
chown ansible /home/ansible/ -R