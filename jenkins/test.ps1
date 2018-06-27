param(    
    [string] $imageTag='sixeyed/jenkins',
    [object[]] $dockerConfig
)

Write-Host "Test script using Docker config: $dockerConfig"

Write-Host "Running container from image: $imageTag"
$id = docker $dockerConfig container run -d -P $imageTag
$ip = docker $dockerConfig container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' $id

Write-Host "Waiting for Jenkins to start"
Start-Sleep -Seconds 10

Write-Host "Fetching HTTP at container IP: $ip"
$response = (iwr -useb "http://$($ip):8080/login")

Write-Host "Removing container ID: $id"
docker $dockerConfig rm -f $id

if ($response.StatusCode -eq 200) {
    Write-Host 'Test passed - received 200 OK'
    exit 0
} else {
    Write-Host "Test failed"
    exit 1
}
