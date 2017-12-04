# Frequent Flyer
An iOS front-end for Concourse. Here's our public Tracker page:

https://www.pivotaltracker.com/n/projects/1860657

## Contributing

0) Get dependencies:<br />
[Carthage](https://github.com/Carthage/Carthage#installing-carthage)<br />
[golang](https://golang.org/doc/install)<br />
[fastlane](https://github.com/fastlane/fastlane#installation)
[xUnique](https://github.com/truebit/xUnique#installation)

1) Clone:
```
git clone https://github.com/jwfriese/FrequentFlyer
cd FrequentFlyer
```

2) Carthage:
```
carthage update --platform 'iOS'
```

3) Start test server in a separate shell. The test suite for the `HTTPClient` class depends on responses served by this test server:
```
go run TestServer/server.go
```

You could also start it in the background in your current shell:
```
go run TestServer/server.go &
```

4) Test with `fastlane`:
```
fastlane scan
```

5) Contribute away!
