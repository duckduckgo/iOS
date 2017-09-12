## Server for Mock Pages

The integration tests require that the mocks are available via a server. To tun a python server:

`cd <project_root>/IntegrationTests/TrackerPageMocks`
`python -m SimpleHTTPServer 8000`

You should now be able to naviagte to a tracker page mock http://localhost:8000/resourcetrackers.html
