
#!/bin/bash
# This script sets the DetectChanges parameter to false for multiple pipelines
# We need to have the AWS CLI installed and configured with your credentials and region
# We will also need to create a pipelines.txt file with the names of the pipelines, each name should be in new line

# Replace this with the name of the txt file that contains the pipeline names, one per line
PIPELINE_FILE="pipelines.txt"

# Loop over the pipeline names from the txt file
while read PIPELINE_NAME; do
  # Get the current pipeline structure as a JSON file
  aws codepipeline get-pipeline --name $PIPELINE_NAME --output json > pipeline.json

  # Modify the JSON file to set the DetectChanges parameter to false for the source action
  jq 'del(.metadata) | .pipeline.stages[0].actions[0].configuration.DetectChanges = "false"' pipeline.json > updated.json

  # Update the pipeline with the modified JSON file and save the output in the output.txt file
  aws codepipeline update-pipeline --output json --cli-input-json file://updated.json | jq '.pipeline | {name, region: .stages[0].actions[0].region, stages: [.stages[0].actions[0].configuration | {BranchName, DetectChanges, FullRepositoryId}]}' >> output.txt

  # Delete the temporary JSON files
  rm pipeline.json updated.json
done < "$PIPELINE_FILE"
