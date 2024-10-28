fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::configure().compile_protos(
        &[
            "proto/tensorflow_serving/apis/prediction_service.proto",
            "proto/tensorflow/core/protobuf/config.proto",
            "proto/tensorflow_serving/apis/prediction_log.proto",
        ],
        &["proto"],
    )?;

    Ok(())
}
