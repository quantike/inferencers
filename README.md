# inferencers

For figuring out gRPC w/ various model serving platforms.

## Getting Started

First, run the protobuf install script:

```sh
sh clone-protos.sh
```

You should now see

```sh
tree proto -L 1

proto/
├── tensorflow/
├── tensorflow_serving/
└── third_party/

4 directories, 0 files
```

> **⚠ WARNING ⚠**: I went in and **hand modified** the `.proto` files. 
> 
> Horrific. I know. 
> 
> The reason is that the `xla` dependency is now considered a `third_party` import in modern `tensorflow` protobuf definitions. 
> 
> This means that in order for your code to compile **you will need to modify all instances of `xla/tsl/...` to `third_party/xla/xla/tsl/...`**. This can be done by hand (tediously) or with a fancy grep call (recommended).

Second, compile your protobuf with the `build.rs` script.

```sh 
cargo build
```

This should not produce any errors if you followed the script above.

## What's Supported?

Right now the functionality is limited. 

| Platform                 | Protocols Supported | Model Types               | Deployment Method      | Language Support | Special Features            | Notes                        |
|--------------------------|---------------------|---------------------------|------------------------|-----------------|-----------------------------|------------------------------|
| TensorFlow Serving       | gRPC, REST          | TensorFlow, Keras         | Docker, Binary         | *                | Dynamic batching, GPU support | Supports multiple models per server |
| TorchServe               | REST, gRPC          | PyTorch                   | Docker, Binary         | *                | Custom handlers, Metrics    | Optimized for PyTorch models |
| ONNX Runtime             | REST, gRPC (via Triton) | ONNX, PyTorch, TensorFlow | Docker, Library       | *             | Hardware acceleration     | Supports quantization and edge deployment |
