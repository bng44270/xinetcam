# xinetcam
xinetd service to take return current webcam pictures

### Build Requirements
* xinetd
* make

### Run requirements
* xinetd
* fswebcam

### Installation
1. Run ```make setup``` and provide the port number to run service as
2. Run ```sudo make install```

### Usage
Return a JPEG image from the default webcam when the following URL is accessed:  
```http://HOST:PORT/<DEVICE>```  
  
This is where ```<DEVICE>``` corresponds to anything beginning with ```/dev/video```.  
  
A list of available camera URLs is available at the following URL:  
```http://HOST:PORT/list```
