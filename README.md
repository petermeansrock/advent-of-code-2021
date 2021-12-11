# Advent of Code 2021 🎄

[![Build Status][build-badge]][build-link] [![codecov][codecov-badge]][codecov-link]

| Day | Structures and Protocols | Unit Test Solutions | Language Features Learned |
| :---: | --- | --- | --- |
| 1 | [`Sonar`][day1] | Part [1][day1-1], [2][day1-2] | Creating tuples of consecutive array elements with [`zip` and `Arrays.dropFirst()`][zip] |
| 2 | [`Submarine`][day2] | Part [1][day2-1], [2][day2-2] | Using [implicit member expression and exteral/internal parameter naming][expressions] |
| 3 | [`DiagnosticReport`][day3] | Part [1][day3-1], [2][day3-2] | Accumulating into a dictionary with [`reduce(into: [:])`][reduce-into] |
| 4 | [`Board`, `BoardSystem`][day4] | Part [1][day4-1], [2][day4-2] | None |
| 5 | [`Plot`, `LineSegment`, `Coordinate`][day5] | Part [1][day5-1], [2][day5-2] | [Error handling][errors] |
| 6 | [`Spawner`][day6] | Part [1][day6-1], [2][day6-2] | None |
| 7 | [`FuelOptimizer`, `FuelEfficiency`][day7] | Part [1][day7-1], [2][day7-2] | Calling [`fatalError`][fatal] for unreachable code |
| 8 | [`SevenSegmentDisplay`][day8] | Part [1][day8-1], [2][day8-2] | [Package vending][vending], [dependency specification][dependency], and [dependency pinning][pinning]
| 9 | [`OceanFloor`, `Basin`][day9] | Part [1][day9-1], [2][day9-2] | [Marking methods with `@discardableResult`][discardable] to avoid compile-time warnings about unused return values
| 10 | [`ChunkLineParser`][day10] | Part [1][day10-1], [2][day10-2] | [Defining][enum-associated-define], [instantiating][enum-associated-init], and [consuming][enum-associated-consume] enumerations with associated values

[day1]: Sources/Library/Sonar.swift
[day1-1]: Tests/LibraryTests/SonarTests.swift#L30-L40
[day1-2]: Tests/LibraryTests/SonarTests.swift#L65-L75
[day2]: Sources/Library/Submarine.swift
[day2-1]: Tests/LibraryTests/SubmarineTests.swift#L28-L40
[day2-2]: Tests/LibraryTests/SubmarineTests.swift#L63-L75
[day3]: Sources/Library/Diagnostic.swift
[day3-1]: Tests/LibraryTests/DiagnosticTests.swift#L40
[day3-2]: Tests/LibraryTests/DiagnosticTests.swift#L41
[day4]: Sources/Library/Bingo.swift
[day4-1]: Tests/LibraryTests/BingoTests.swift#L40-L50
[day4-2]: Tests/LibraryTests/BingoTests.swift#L85-L95
[day5]: https://github.com/petermeansrock/advent-of-code-swift/blob/main/Sources/AdventOfCode/Geometry.swift
[day5-1]: Tests/LibraryTests/GeometryTests.swift#L7-L24
[day5-2]: Tests/LibraryTests/GeometryTests.swift#L26-L43
[day6]: Sources/Library/Spawner.swift
[day6-1]: Tests/LibraryTests/SpawnerTests.swift#L43-L55
[day6-2]: Tests/LibraryTests/SpawnerTests.swift#L57-L69
[day7]: Sources/Library/Fuel.swift
[day7-1]: Tests/LibraryTests/FuelTests.swift#L19-L33
[day7-2]: Tests/LibraryTests/FuelTests.swift#L47-L61
[day8]: Sources/Library/Display.swift
[day8-1]: Tests/LibraryTests/DisplayTests.swift#L48-L74
[day8-2]: Tests/LibraryTests/DisplayTests.swift#L118-L131
[day9]: Sources/Library/Floor.swift
[day9-1]: Tests/LibraryTests/FloorTests.swift#L44-L73
[day9-2]: Tests/LibraryTests/FloorTests.swift#L44-L73
[day10]: Sources/Library/Syntax.swift
[day10-1]: Tests/LibraryTests/SyntaxTests.swift#L41-L62
[day10-2]: Tests/LibraryTests/SyntaxTests.swift#L99-L121

[zip]: Sources/Library/Sonar.swift#L45
[expressions]: Sources/Library/Submarine.swift#L62
[reduce-into]: Sources/Library/Diagnostic.swift#L62-L63
[errors]: https://github.com/petermeansrock/advent-of-code-swift/blob/main/Sources/AdventOfCode/Geometry.swift#L137-L142
[fatal]: Sources/Library/Fuel.swift#L113
[vending]: https://github.com/petermeansrock/advent-of-code-swift/releases
[dependency]: Package.swift#L14-L26
[pinning]: Package.resolved
[discardable]: Sources/Library/Floor.swift#L46-L63
[enum-associated-define]: Sources/Library/Syntax.swift#L71-L89
[enum-associated-init]: Sources/Library/Syntax.swift#L106
[enum-associated-consume]: Tests/LibraryTests/SyntaxTests.swift#L28-L33

[build-badge]: https://github.com/petermeansrock/advent-of-code-2021/actions/workflows/swift.yml/badge.svg
[build-link]: https://github.com/petermeansrock/advent-of-code-2021/actions
[codecov-badge]: https://codecov.io/gh/petermeansrock/advent-of-code-2021/branch/main/graph/badge.svg
[codecov-link]: https://codecov.io/gh/petermeansrock/advent-of-code-2021
