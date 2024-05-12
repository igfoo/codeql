import java
import semmle.code.java.dataflow.TaintTracking

module DecompressionBomb {
  /**
   * The Decompression bomb Sink
   *
   * Extend this class for creating new decompression bomb sinks
   */
  class Sink extends Unit {
    abstract predicate sink(DataFlow::Node sink, DataFlow::FlowState state);
  }

  /**
   * The Additional flow steps that help to create a dataflow or taint tracking query
   *
   * Extend this class for creating new additional taint steps
   */
  class AdditionalStep extends Unit {
    abstract predicate step(
      DataFlow::Node n1, DataFlow::FlowState stateFrom, DataFlow::Node n2,
      DataFlow::FlowState stateTo
    );
  }
}

/**
 * Providing Decompression sinks and additional taint steps for `org.xerial.snappy` package
 */
module XerialSnappy {
  /**
   * A type that is responsible for `SnappyInputStream` Class
   */
  class TypeInputStream extends RefType {
    TypeInputStream() {
      this.getASupertype*().hasQualifiedName("org.xerial.snappy", "SnappyInputStream")
    }
  }

  /**
   * Gets `n1` and `n2` which `SnappyInputStream n2 = new SnappyInputStream(n1)` or
   * `n1.read(n2)`,
   *  second one is added because of sanitizer, we want to compare return value of each `read` or similar method
   *  that whether there is a flow to a comparison between total read of decompressed stream and a constant value
   */
  private class InputStreamAdditionalTaintStep extends DecompressionBomb::AdditionalStep {
    override predicate step(
      DataFlow::Node n1, DataFlow::FlowState stateFrom, DataFlow::Node n2,
      DataFlow::FlowState stateTo
    ) {
      exists(Call call |
        // Constructors
        call.getCallee().getDeclaringType() = any(TypeInputStream t) and
        call.getArgument(0) = n1.asExpr() and
        call = n2.asExpr()
        or
        // Method calls
        call.(MethodCall).getReceiverType() = any(TypeInputStream t) and
        call.getCallee().hasName(["read", "readNBytes", "readAllBytes"]) and
        call.getQualifier() = n1.asExpr() and
        call = n2.asExpr()
      ) and
      stateFrom = "XerialSnappy" and
      stateTo = "XerialSnappy"
    }
  }

  /**
   * The methods that read bytes and belong to `SnappyInputStream` Types
   */
  class ReadInputStreamCall extends MethodCall {
    ReadInputStreamCall() {
      this.getReceiverType() instanceof TypeInputStream and
      this.getCallee().hasName(["read", "readNBytes", "readAllBytes"])
    }

    /**
     * A method Access as a sink which responsible for reading bytes
     */
    MethodCall getAByteRead() { result = this }

    // look at Zip4j comments for this method
    predicate isControlledRead() { none() }
  }

  class Sink extends DecompressionBomb::Sink {
    override predicate sink(DataFlow::Node sink, DataFlow::FlowState state) {
      sink.asExpr() = any(ReadInputStreamCall r).getAByteRead() and state = "XerialSnappy"
    }
  }
}

/**
 * Providing Decompression sinks and additional taint steps for `org.apache.commons.compress` package
 */
module ApacheCommons {
  /**
   * A type that is responsible for `ArchiveInputStream` Class
   */
  class TypeArchiveInputStream extends RefType {
    TypeArchiveInputStream() {
      this.getASupertype*()
          .hasQualifiedName("org.apache.commons.compress.archivers", "ArchiveInputStream")
    }
  }

  /**
   * A type that is responsible for `CompressorInputStream` Class
   */
  class TypeCompressorInputStream extends RefType {
    TypeCompressorInputStream() {
      this.getASupertype*()
          .hasQualifiedName("org.apache.commons.compress.compressors", "CompressorInputStream")
    }
  }

  /**
   * Providing Decompression sinks and additional taint steps for `org.apache.commons.compress.compressors.*` Types
   */
  module Compressors {
    /**
     * The types that are responsible for specific compression format of `CompressorInputStream` Class
     */
    class TypeCompressors extends RefType {
      TypeCompressors() {
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.compressors.gzip",
              "GzipCompressorInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.compressors.brotli",
              "BrotliCompressorInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.compressors.bzip2",
              "BZip2CompressorInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.compressors.deflate",
              "DeflateCompressorInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.compressors.deflate64",
              "Deflate64CompressorInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.compressors.lz4",
              "BlockLZ4CompressorInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.compressors.lzma",
              "LZMACompressorInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.compressors.pack200",
              "Pack200CompressorInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.compressors.snappy",
              "SnappyCompressorInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.compressors.xz",
              "XZCompressorInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.compressors.z", "ZCompressorInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.compressors.zstandard",
              "ZstdCompressorInputStream")
      }
    }

    /**
     * Gets `n1` and `n2` which `*CompressorInputStream n2 = new *CompressorInputStream(n2)` or
     * `n2 = inputStream.read(n1)` or `n1.read(n2)`,
     *  second one is added because of sanitizer, we want to compare return value of each `read` or similar method
     *  that whether there is a flow to a comparison between total read of decompressed stream and a constant value
     */
    private class CompressorsAdditionalTaintStep extends DecompressionBomb::AdditionalStep {
      override predicate step(
        DataFlow::Node n1, DataFlow::FlowState stateFrom, DataFlow::Node n2,
        DataFlow::FlowState stateTo
      ) {
        exists(Call call |
          // Constructors
          call.getCallee().getDeclaringType() = any(TypeCompressors t) and
          call.getArgument(0) = n1.asExpr() and
          call = n2.asExpr()
          or
          // Method calls
          call.(MethodCall).getReceiverType() = any(TypeCompressors t) and
          call.getCallee().hasName(["read", "readNBytes", "readAllBytes"]) and
          call.getQualifier() = n1.asExpr() and
          call = n2.asExpr()
        ) and
        stateFrom = "ApacheCommons" and
        stateTo = "ApacheCommons"
      }
    }

    /**
     * The methods that read bytes and belong to `*CompressorInputStream` Types
     */
    class ReadInputStreamCall extends MethodCall {
      ReadInputStreamCall() {
        this.getReceiverType() instanceof TypeCompressors and
        this.getCallee().hasName(["read", "readNBytes", "readAllBytes"])
      }

      /**
       * A method Access as a sink which responsible for reading bytes
       */
      MethodCall getAByteRead() { result = this }

      // look at Zip4j comments for this method
      predicate isControlledRead() { none() }
    }

    class Sink extends DecompressionBomb::Sink {
      override predicate sink(DataFlow::Node sink, DataFlow::FlowState state) {
        sink.asExpr() = any(ReadInputStreamCall r).getAByteRead() and state = "ApacheCommons"
      }
    }
  }

  /**
   * Providing Decompression sinks and additional taint steps for Types from `org.apache.commons.compress.archivers.*` packages
   */
  module Archivers {
    /**
     * The types that are responsible for specific compression format of `ArchiveInputStream` Class
     */
    class TypeArchivers extends RefType {
      TypeArchivers() {
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.archivers.ar", "ArArchiveInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.archivers.arj", "ArjArchiveInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.archivers.cpio", "CpioArchiveInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.archivers.ar", "ArArchiveInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.archivers.jar", "JarArchiveInputStream") or
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.archivers.zip", "ZipArchiveInputStream")
      }
    }

    /**
     * Gets `n1` and `n2` which `*ArchiveInputStream n2 = new *ArchiveInputStream(n2)` or
     * `n2 = inputStream.read(n2)` or `n1.read(n2)`,
     *  second one is added because of sanitizer, we want to compare return value of each `read` or similar method
     *  that whether there is a flow to a comparison between total read of decompressed stream and a constant value
     */
    private class ArchiversAdditionalTaintStep extends DecompressionBomb::AdditionalStep {
      override predicate step(
        DataFlow::Node n1, DataFlow::FlowState stateFrom, DataFlow::Node n2,
        DataFlow::FlowState stateTo
      ) {
        exists(Call call |
          // Constructors
          call.getCallee().getDeclaringType() = any(TypeArchivers t) and
          call.getArgument(0) = n1.asExpr() and
          call = n2.asExpr()
          or
          // Method calls
          call.(MethodCall).getReceiverType() = any(TypeArchivers t) and
          call.getCallee().hasName(["read", "readNBytes", "readAllBytes"]) and
          call.getQualifier() = n1.asExpr() and
          call = n2.asExpr()
        ) and
        stateFrom = "ApacheCommons" and
        stateTo = "ApacheCommons"
      }
    }

    /**
     * The methods that read bytes and belong to `*ArchiveInputStream` Types
     */
    class ReadInputStreamCall extends MethodCall {
      ReadInputStreamCall() {
        this.getReceiverType() instanceof TypeArchivers and
        this.getCallee().hasName(["read", "readNBytes", "readAllBytes"])
      }

      /**
       * A method Access as a sink which responsible for reading bytes
       */
      MethodCall getAByteRead() { result = this }

      // look at Zip4j comments for this method
      predicate isControlledRead() { none() }
    }

    class Sink extends DecompressionBomb::Sink {
      override predicate sink(DataFlow::Node sink, DataFlow::FlowState state) {
        sink.asExpr() = any(ReadInputStreamCall r).getAByteRead() and state = "ApacheCommons"
      }
    }
  }

  /**
   * Providing Decompression sinks and additional taint steps for `CompressorStreamFactory` and `ArchiveStreamFactory` Types
   */
  module Factory {
    /**
     * A type that is responsible for `ArchiveInputStream` Class
     */
    class TypeArchivers extends RefType {
      TypeArchivers() {
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.archivers", "ArchiveStreamFactory")
      }
    }

    /**
     * A type that is responsible for `CompressorStreamFactory` Class
     */
    class TypeCompressors extends RefType {
      TypeCompressors() {
        this.getASupertype*()
            .hasQualifiedName("org.apache.commons.compress.compressors", "CompressorStreamFactory")
      }
    }

    /**
     * Gets `n1` and `n2` which `CompressorInputStream n2 = new CompressorStreamFactory().createCompressorInputStream(n1)`
     * or `ArchiveInputStream n2 = new ArchiveStreamFactory().createArchiveInputStream(n1)` or
     * `n1.read(n2)`,
     * second one is added because of sanitizer, we want to compare return value of each `read` or similar method
     * that whether there is a flow to a comparison between total read of decompressed stream and a constant value
     */
    private class CompressorsAndArchiversAdditionalTaintStep extends DecompressionBomb::AdditionalStep
    {
      override predicate step(
        DataFlow::Node n1, DataFlow::FlowState stateFrom, DataFlow::Node n2,
        DataFlow::FlowState stateTo
      ) {
        exists(Call call |
          // Constructors
          (
            call.getCallee().getDeclaringType() = any(TypeCompressors t)
            or
            call.getCallee().getDeclaringType() = any(TypeArchivers t)
          ) and
          call.getArgument(0) = n1.asExpr() and
          call = n2.asExpr()
          or
          // Method calls
          (
            call.(MethodCall).getReceiverType() = any(TypeArchiveInputStream t)
            or
            call.(MethodCall).getReceiverType() = any(TypeCompressorInputStream t)
          ) and
          call.getCallee().hasName(["read", "readNBytes", "readAllBytes"]) and
          call.getQualifier() = n1.asExpr() and
          call = n2.asExpr()
        ) and
        stateFrom = "ApacheCommons" and
        stateTo = "ApacheCommons"
      }
    }

    /**
     * The methods that read bytes and belong to `CompressorInputStream` or `ArchiveInputStream` Types
     */
    class ReadInputStreamCall extends MethodCall {
      ReadInputStreamCall() {
        (
          this.getReceiverType() instanceof TypeArchiveInputStream
          or
          this.getReceiverType() instanceof TypeCompressorInputStream
        ) and
        this.getCallee().hasName(["read", "readNBytes", "readAllBytes"])
      }

      /**
       * A method Access as a sink which responsible for reading bytes
       */
      MethodCall getAByteRead() { result = this }

      // look at Zip4j comments for this method
      predicate isControlledRead() { none() }
    }

    class Sink extends DecompressionBomb::Sink {
      override predicate sink(DataFlow::Node sink, DataFlow::FlowState state) {
        sink.asExpr() = any(ReadInputStreamCall r).getAByteRead() and state = "ApacheCommons"
      }
    }
  }
}

/**
 * Providing Decompression sinks and additional taint steps for `net.lingala.zip4j.io` package
 */
module Zip4j {
  /**
   * A type that is responsible for `ZipInputStream` Class
   */
  class TypeZipInputStream extends RefType {
    TypeZipInputStream() {
      this.hasQualifiedName("net.lingala.zip4j.io.inputstream", "ZipInputStream")
    }
  }

  /**
   * The methods that read bytes and belong to `CompressorInputStream` or `ArchiveInputStream` Types
   */
  class ReadInputStreamCall extends MethodCall {
    ReadInputStreamCall() {
      this.getReceiverType() instanceof TypeZipInputStream and
      this.getMethod().hasName(["read", "readNBytes", "readAllBytes"])
    }

    /**
     * A method Access as a sink which responsible for reading bytes
     */
    MethodCall getAByteRead() { result = this }

    // while ((readLen = zipInputStream.read(readBuffer)) != -1) {
    //   totallRead += readLen;
    //   if (totallRead > 1024 * 1024 * 4) {
    //     System.out.println("potential Bomb");
    //     break;
    //   }
    //   outputStream.write(readBuffer, 0, readLen);
    // }
    // TODO: I don't know why we can't reach totallRead with Local Tainting
    // the same behaviour exists in golang
    predicate isControlledRead() {
      exists(ComparisonExpr i |
        TaintTracking::localExprTaint([this, this.getArgument(2)], i.getAChildExpr*())
      )
    }
  }

  class Sink extends DecompressionBomb::Sink {
    override predicate sink(DataFlow::Node sink, DataFlow::FlowState state) {
      sink.asExpr() = any(ReadInputStreamCall r).getAByteRead() and state = "Zip4j"
    }
  }

  /**
   * Gets `n1` and `n2` which `ZipInputStream n2 = new ZipInputStream(n1)` or `n2 = zipInputStream.read(n1)` or `n1.read(n2)`,
   * second one is added because of sanitizer, we want to compare return value of each `read` or similar method
   * that whether there is a flow to a comparison between total read of decompressed stream and a constant value
   */
  private class InputStreamAdditionalTaintStep extends DecompressionBomb::AdditionalStep {
    override predicate step(
      DataFlow::Node n1, DataFlow::FlowState stateFrom, DataFlow::Node n2,
      DataFlow::FlowState stateTo
    ) {
      exists(Call call |
        // Constructors
        call.getCallee().getDeclaringType() = any(TypeZipInputStream t) and
        call.getArgument(0) = n1.asExpr() and
        call = n2.asExpr()
        or
        // Method calls
        call.(MethodCall).getReceiverType() = any(TypeZipInputStream t) and
        call.getCallee().hasName(["read", "readNBytes", "readAllBytes"]) and
        call.getQualifier() = n1.asExpr() and
        call = n2.asExpr()
      ) and
      stateFrom = "Zip4j" and
      stateTo = "Zip4j"
    }
  }
}

/**
 * Providing sinks that can be related to reading uncontrolled buffer and bytes for `org.apache.commons.io` package
 */
module CommonsIO {
  /**
   * The Access to Methods which work with byes and inputStreams and buffers
   */
  class IOUtils extends MethodCall {
    IOUtils() {
      this.getMethod()
          .hasName([
              "copy", "copyLarge", "read", "readFully", "readLines", "toBufferedInputStream",
              "toByteArray", "toCharArray", "toString", "buffer"
            ]) and
      this.getMethod().getDeclaringType().hasQualifiedName("org.apache.commons.io", "IOUtils")
    }
  }

  class Sink extends DecompressionBomb::Sink {
    override predicate sink(DataFlow::Node sink, DataFlow::FlowState state) {
      sink.asExpr() = any(IOUtils r).getArgument(0) and
      state = ["ZipFile", "Zip4j", "inflator", "UtilZip", "ApacheCommons", "XerialSnappy"]
    }
  }
}

/**
 * Providing Decompression sinks and additional taint steps for `java.util.zip` package
 */
module Zip {
  /**
   * The Types that are responsible for `ZipInputStream`, `GZIPInputStream`, `InflaterInputStream` Classes
   */
  class TypeInputStream extends RefType {
    TypeInputStream() {
      this.getASupertype*()
          .hasQualifiedName("java.util.zip",
            ["ZipInputStream", "GZIPInputStream", "InflaterInputStream"])
    }
  }

  /**
   * The methods that read bytes and belong to `*InputStream` Types
   */
  class ReadInputStreamCall extends MethodCall {
    ReadInputStreamCall() {
      this.getReceiverType() instanceof TypeInputStream and
      this.getCallee().hasName(["read", "readNBytes", "readAllBytes"])
    }

    /**
     * A method Access as a sink which responsible for reading bytes
     */
    MethodCall getAByteRead() { result = this }

    // look at Zip4j comments for this method
    predicate isControlledRead() { none() }
  }

  class ReadInputStreamSink extends DecompressionBomb::Sink {
    override predicate sink(DataFlow::Node sink, DataFlow::FlowState state) {
      sink.asExpr() = any(ReadInputStreamCall r).getAByteRead() and state = "UtilZip"
    }
  }

  /**
   * Gets `n1` and `n2` which `*InputStream n2 = new *InputStream(n1)` or
   * `n2 = data.read(n1, 0, BUFFER)` or `n1.read(n2, 0, BUFFER)`,
   * second one is added because of sanitizer, we want to compare return value of each `read` or similar method
   * that whether there is a flow to a comparison between total read of decompressed stream and a constant value
   */
  private class InputStreamAdditionalTaintStep extends DecompressionBomb::AdditionalStep {
    override predicate step(
      DataFlow::Node n1, DataFlow::FlowState stateFrom, DataFlow::Node n2,
      DataFlow::FlowState stateTo
    ) {
      exists(Call call |
        // Constructors
        call.getCallee().getDeclaringType() = any(TypeInputStream t) and
        call.getArgument(0) = n1.asExpr() and
        call = n2.asExpr()
        or
        // Method calls
        call.(MethodCall).getReceiverType() = any(TypeInputStream t) and
        call.getCallee().hasName(["read", "readNBytes", "readAllBytes"]) and
        call.getQualifier() = n1.asExpr() and
        call = n2.asExpr()
      ) and
      stateFrom = "UtilZip" and
      stateTo = "UtilZip"
    }
  }

  /**
   * A type that is responsible for `Inflater` Class
   */
  class TypeInflator extends RefType {
    TypeInflator() { this.hasQualifiedName("java.util.zip", "Inflater") }
  }

  /**
   * Gets `n1` and `n2` which `Inflater inflater_As_n2 = new Inflater(); inflater_As_n2 = inflater.setInput(n1)` or `n1.inflate(n2)` or
   * `n2 = inflater.inflate(n1)`,
   * third one is added because of sanitizer, we want to compare return value of each `read` or similar method
   * that whether there is a flow to a comparison between total read of decompressed stream and a constant value
   */
  private class InflatorAdditionalTaintStep extends DecompressionBomb::AdditionalStep {
    override predicate step(
      DataFlow::Node n1, DataFlow::FlowState stateFrom, DataFlow::Node n2,
      DataFlow::FlowState stateTo
    ) {
      // n1.inflate(n2)
      (
        exists(MethodCall ma |
          ma.getReceiverType() instanceof TypeInflator and
          ma.getArgument(0) = n2.asExpr() and
          ma.getQualifier() = n1.asExpr() and
          ma.getCallee().hasName("inflate")
        )
        or
        // n2 = inflater.inflate(n1)
        exists(MethodCall ma |
          ma.getReceiverType() instanceof TypeInflator and
          ma = n2.asExpr() and
          ma.getArgument(0) = n1.asExpr() and
          ma.getCallee().hasName("inflate")
        )
        or
        // Inflater inflater = new Inflater();
        // inflater_As_n2 = inflater.setInput(n1)
        exists(MethodCall ma |
          ma.getReceiverType() instanceof TypeInflator and
          n1.asExpr() = ma.getArgument(0) and
          n2.(DataFlow::PostUpdateNode).getPreUpdateNode().asExpr() = ma.getQualifier() and
          ma.getCallee().hasName("setInput")
        )
      ) and
      stateFrom = "inflator" and
      stateTo = "inflator"
    }
  }

  /**
   * The methods that read bytes and belong to `Inflater` Type
   */
  class InflateCall extends MethodCall {
    InflateCall() {
      this.getReceiverType() instanceof TypeInflator and
      this.getCallee().hasName("inflate")
    }

    /**
     * A method Access as a sink which responsible for reading bytes
     */
    MethodCall getAByteRead() { result = this }

    // look at Zip4j comments for this method
    predicate isControlledRead() { none() }
  }

  class InflateSink extends DecompressionBomb::Sink {
    override predicate sink(DataFlow::Node sink, DataFlow::FlowState state) {
      sink.asExpr() = any(InflateCall r).getAByteRead() and state = "inflator"
    }
  }

  /**
   * A type that is responsible for `ZipFile` Class
   */
  class TypeZipFile extends RefType {
    TypeZipFile() { this.hasQualifiedName("java.util.zip", "ZipFile") }
  }

  /**
   * Gets `n1` and `n2` which `ZipFile n2 = new ZipFile(n1);` or
   * `InputStream n2 = zipFile.getInputStream(n1);` or `zipFile_As_n1.getInputStream(n2);`
   */
  private class ZipFileAdditionalTaintStep extends DecompressionBomb::AdditionalStep {
    override predicate step(
      DataFlow::Node n1, DataFlow::FlowState stateFrom, DataFlow::Node n2,
      DataFlow::FlowState stateTo
    ) {
      (
        exists(MethodCall ma |
          ma.getReceiverType() instanceof TypeZipFile and
          ma = n2.asExpr() and
          ma.getQualifier() = n1.asExpr() and
          ma.getCallee().hasName("getInputStream")
        )
        or
        exists(Call c |
          c.getCallee().getDeclaringType() instanceof TypeZipFile and
          c.getArgument(0) = n1.asExpr() and
          c = n2.asExpr()
        )
      ) and
      stateFrom = "ZipFile" and
      stateTo = "ZipFile"
    }
  }
}

/**
 * Providing InputStream and it subClasses that mostly related to Sinks of ZipFile Type,
 * we can do
 */
module InputStream {
  /**
   * The Types that are responsible for `InputStream` Class and all classes that are child of InputStream Class
   */
  class TypeInputStream extends RefType {
    TypeInputStream() { this.getASupertype*().hasQualifiedName("java.io", "InputStream") }
  }

  /**
   * The methods that read bytes and belong to `InputStream` Type and all Types that are child of InputStream Type
   */
  class Read extends MethodCall {
    Read() {
      this.getReceiverType() instanceof TypeInputStream and
      this.getCallee().hasName(["read", "readNBytes", "readAllBytes"])
    }
  }

  class ReadSink extends DecompressionBomb::Sink {
    override predicate sink(DataFlow::Node sink, DataFlow::FlowState state) {
      sink.asExpr() = any(Read r) and state = "ZipFile"
    }
  }

  /**
   * general additional taint steps for all inputStream and all Types that are child of inputStream
   */
  private class InputStreamAdditionalTaintStep extends DecompressionBomb::AdditionalStep {
    override predicate step(
      DataFlow::Node n1, DataFlow::FlowState stateFrom, DataFlow::Node n2,
      DataFlow::FlowState stateTo
    ) {
      exists(Call call |
        // Method calls
        call.(MethodCall).getReceiverType() = any(TypeInputStream t) and
        call.getCallee().hasName(["read", "readNBytes", "readAllBytes"]) and
        call.getQualifier() = n1.asExpr() and
        call = n2.asExpr()
      ) and
      stateFrom = "ZipFile" and
      stateTo = "ZipFile"
      or
      exists(Call call |
        // Method calls
        call.(ConstructorCall).getConstructedType().hasQualifiedName("java.util.zip", "ZipFile") and
        n1.asExpr() = call.getAnArgument() and
        n2.asExpr() = call
      ) and
      stateFrom = "ZipFile" and
      stateTo = "ZipFile"
    }
  }
}

predicate step(DataFlow::Node n1, DataFlow::Node n2) {
  exists(Call call |
    // Method calls
    call.(ConstructorCall).getConstructedType().hasQualifiedName("java.util.zip", "ZipFile") and
    n1.asExpr() = call.getAnArgument() and
    n2.asExpr() = call
  )
}
