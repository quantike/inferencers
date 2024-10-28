#!/bin/bash

set -e  # Exit on any error
set -o pipefail  # Ensure pipeline errors are caught
set -u  # Treat unset variables as errors

# Define directories
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
PROTO_DIR="$PROJECT_ROOT/proto"

# Ensure the proto directory exists
mkdir -p "$PROTO_DIR"

# Define repositories and sparse-checkout paths
# Format: "repo_url tmp_dir sparse_path1 sparse_path2 ..."
TARGETS=(
  "https://github.com/tensorflow/serving.git tmp_tf_serving tensorflow_serving/apis tensorflow_serving/config"
  "https://github.com/tensorflow/tensorflow.git tmp_tensorflow tensorflow/core/framework tensorflow/core/example tensorflow/core/protobuf third_party/xla/xla/tsl/protobuf"
)

# Function to clone and sparse-checkout a repository
clone_and_checkout() {
  local repo_url="$1"
  local tmp_dir="$2"
  shift 2  # Skip repo_url and tmp_dir
  local sparse_paths=("$@")

  echo "Cloning $repo_url into $PROTO_DIR/$tmp_dir..."
  git clone --depth 1 --filter=blob:none --no-checkout "$repo_url" "$PROTO_DIR/$tmp_dir"

  cd "$PROTO_DIR/$tmp_dir"

  echo "Setting up sparse-checkout for $repo_url..."
  git sparse-checkout init --cone
  git sparse-checkout set "${sparse_paths[@]}"
  
  echo "Checking out files from $repo_url..."
  git checkout

  echo "Copying .proto files from $repo_url..."
  fd -e proto . | rsync --files-from=- . "$PROTO_DIR"
}

# Iterate over all targets and process each
for target in "${TARGETS[@]}"; do
  IFS=' ' read -r repo_url tmp_dir sparse_paths <<< "$target"
  clone_and_checkout "$repo_url" "$tmp_dir" $sparse_paths
done

# Clean up temporary directories
echo "Cleaning up temporary files..."
for target in "${TARGETS[@]}"; do
  IFS=' ' read -r _ tmp_dir _ <<< "$target"
  rm -rf "$PROTO_DIR/$tmp_dir"
done

echo "Proto files successfully downloaded to $PROTO_DIR!"

