# Snap-it-up

This repo is a really rough work-in-progress/experiment monitoring the availability of various government websites offering access to SNAP benefits (a.k.a. food assistance). Some of this work is code (the site) and some is process and thinking—check out the [issues list](https://github.com/codeforamerica/snap-it-up/issues).

## Why?

What's the point? SNAP services can be critical for those who receive them. However, the online sites and tools related to these services are often down or unavailable. We hope to:

- Let case workers and applicants know when services are down
- Gain a better understanding of how these sites perform and when they’re (not) available
- Help others understand the issue
- Potentially hold state agencies and vendors accountable for poor performance or uptime
- In general, find levers (or use this site *as* a lever) to improve the situation

## Where can I see it?

There are two sites currently related to this work:

- http://status.citizenonboard.com/ Shows basic info about SNAP sites in the state of California and allows anyone to subscribe to notifications when sites go up or down. It's powered by [statuspage.io](https://www.statuspage.io).
- http://snap-status.herokuapp.com/ Is the site built with the code in this repository. At the moment, it's mostly a basis for examination and experimentation, gathering data, and some [very] basic visualizations. We hope to eventually have time to grow it into something more substantial—a tool for educating people unfamiliar with the issue and for people interested in the details to learn more.

Both sites are powered by same underlying monitoring infrastructure. At the moment, that infrastructure is [Pingometer](http://pingometer.com).

## How can I contribute/help/learn more?

Thanks for being interested! First, check out the [issues list](https://github.com/codeforamerica/snap-it-up/issues). Some of the work there is discussion, exploration, and thinking. Feel free to pose questions or read through the discussions if you'd like to pitch in or learn more. Some of the issues are about the actual source code in this repo. If you'd like to contribute code or suggest new things to be added to the site, feel free to add to those issues.

## Licensing

This project is open source and licensed under the [BSD 3-clause license][LICENSE].
Copyright (c) 2014-2015 Code for America. See [LICENSE][] for details.

[LICENSE]: https://github.com/codeforamerica/snap-it-up/blob/master/LICENSE
