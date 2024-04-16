# See https://github.com/nodesource/distributions#debian-and-ubuntu-based-distributions

# Old way
NODE_MAJOR=20
# Download and import the Nodesource GPG key
#apt-get install -y ca-certificates curl gnupg
#mkdir -p /etc/apt/keyrings
#curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
# Create deb repository
#echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
# Run Update and Install
#apt-get update
#apt-get install nodejs -y

# New Way
# It doesn't seem that I need to run the below commented out commands.
# apt-get remove nodejs -y
# apt-get purge nodejs -y
# apt-get autoremove -y
# apt-get update
curl -sL https://deb.nodesource.com/setup_20.x | bash
apt-get install nodejs -y
