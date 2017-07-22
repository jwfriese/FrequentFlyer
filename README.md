# Frequent Flyer
An iOS front-end for Concourse. Here's our public Tracker page:

https://www.pivotaltracker.com/n/projects/1860657

## Contributing

0) Get dependencies:<br />
[Carthage](https://github.com/Carthage/Carthage#installing-carthage)<br />
[xcpretty](https://github.com/supermarin/xcpretty#installation)<br />
[golang](https://golang.org/doc/install)<br />

1) Clone:
```
git clone https://github.com/jwfriese/FrequentFlyer
cd FrequentFlyer
```

2) Carthage:
```
carthage update --platform 'iOS'
```

3) Start test server in a separate shell. The test suite for the `HTTPClient` class redepends on responses served by this test server:
```
go run TestServer/server.go
```

4) Test:
```
go get -u github.com/jwfriese/iossimulator
go build script/test.go
./test 'iOS 10.0' 'iPhone 6'
```

5) Contribute away!
