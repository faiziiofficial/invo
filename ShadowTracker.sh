# Install Docker and start the Docker service
sudo yum install docker -y
sudo systemctl start docker

# Update system packages and install MariaDB 10.5 server
sudo dnf update -y 
sudo dnf install mariadb105-server -y

# Extract database endpoint information from the file "db_endpoint" and export it
export $(cat ../db_endpoint | sed 's/:3306//g')

# Check if a connection to the MariaDB server can be established
if mysqladmin ping -u phalcon -p"secret1234" -h $DB_HOST -P 3306 --connect-timeout 2
then
    echo "DB connection established!"
else
    echo "DB connection failed!"
fi

# Replace "localhost" in the .env.example file with the DB_HOST and save it as .env
cat .env.example | sed "s/localhost/$DB_HOST/g" > .env
cat .env

# Build Docker Image for 8.0 falcon
echo "Building Docker Image for 8.0 falcon"
cd docker/8.0
sudo docker build -t falcon:v1 .

# Run Docker container named "falcon" based on the built image, mapping port 80 to host
sudo docker run -itd --name falcon -p 80:80 falcon:v1
