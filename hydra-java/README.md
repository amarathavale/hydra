# Hydra-Java

Hydra is a type-aware data transformation toolkit which aims to be highly flexible and portable.
It has its roots in graph databases and type theory, and provides APIs in Haskell and Java.
See the main Hydra [README](https://github.com/CategoricalData/hydra) for more details.
This package contains Hydra's Java API and Java sources specifically.

## Build

Build the Java project with `./gradlew build`, or publish the resulting JAR to your local Maven repository with `./gradlew publishToMavenLocal`. This project requires Java 11 so you may need to set the `JAVA_HOME` environment variable accordingly: `JAVA_HOME=/path/to/java11/installation ./gradlew build`.

