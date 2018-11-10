# Benchgraph

Easily visualisation of the evolution of your benchmarks.

[![CircleCI](https://circleci.com/gh/novadiscovery/benchgraph/tree/master.svg?style=svg)](https://circleci.com/gh/novadiscovery/benchgraph/tree/master)

## Wat's benchgraph?

`Benchgraph` is a tool which helps you to see how your benchmarks evolve
through the lifetime of your program.

## Why do I need it

Wants to see if a new feature will slow your library down?
Wants to know why your users complains that your program starts getting slower?
That's what `Benchgraph` is for.

## Enough jabbing, I want nice pictures and buzzwords

All right, all righ.

First, here's a picture of a [blockchain-generated
cat](https://www.cryptokitties.co/):

![](https://www.cryptokitties.co/images/landing-kitty02.svg)

Now, here's a screenshot of `benchgraph` in action on one of our internal
benchmark suite:

![](http://www.image-share.com/upload/3872/158.png)

## Wah, I'm conviced! How do I use it?

To use this, just follow these two simple steps:

1. Export your benchmarks results to the format accepted by the `benchgraph`
  server
2. Run the server

### Export your results

The benchgraph server reads the benchmarks results as an array in
[nd-json](http://ndjson.org/) format, where each line contains a record of the
form (without the newlines obviously):

```json
{
  "bench_name": "MyBench";
  "commit_rev": "Id of the commit";
  "timestamp": "the date of the commit";
  "time_in_nanos": "Duration of the benchmark";
}
```

We provide adapters for some benchmarking frameworks (only
[criterion](http://www.serpentine.com/criterion/) at the moment, but you're
welcome to add more) so that the export is one simple command line.

### Run the server

The server is provided as a docker image.

If your benchmark results are all in the `benchmarks` directory, you can simply
run:

```sh
docker pull benchgraph/benchgraph:master
docker run \
  -p 8123:8123
  -v $PWD/benchmarks:/benchmarks benchgraph/benchgraph:master \
  /bin/benchgraph /benchmarks
```
