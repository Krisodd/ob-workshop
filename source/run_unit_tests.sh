#!/bin/bash
# project names
declare -a projects=(
    "PaymentApi.Unittest"
)

# change path for local testing
# declare base_path="/c/temp/test_output"
declare base_path="/build/test_output"
export PATH="$PATH:/root/.dotnet/tools"
dotnet tool install --global trx2junit
dotnet tool install -g dotnet-reportgenerator-globaltool 

for project in "${projects[@]}"
do
    echo "./$project/$project.csproj"
    mkdir -p $base_path/$project
    if [ "$project" = ${projects[-1]} ]; then
        dotnet test --no-build -c Release --logger "trx;LogFileName=$base_path/$project/output.trx" ./$project/$project.csproj /p:CollectCoverage=true \
        /p:Exclude="[*]Spv.Evry.WsProxy.Common.*%2c[*]paymentApi.Repositories.Evry.*" /p:CoverletOutputFormat=cobertura /p:CoverletOutput=../ /p:MergeWith='../coverage.cobertura.xml' \
        /p:Threshold=29 /p:ThresholdType=line /p:ThresholdStat=total || echo "$project" >> $base_path/failed_tests
    else
        dotnet test --no-build -c Release --logger "trx;LogFileName=$base_path/$project/output.trx" ./$project/$project.csproj /p:CollectCoverage=true \
        /p:Exclude="[*]Spv.Evry.WsProxy.Common.*%2c[*]paymentApi.Repositories.Evry.*" /p:CoverletOutputFormat=cobertura /p:CoverletOutput=../ /p:MergeWith='../coverage.cobertura.xml' \
        || echo "$project" >> $base_path/failed_tests
    fi
done
trx2junit $base_path/$project/output.trx
reportgenerator "-reports:coverage.cobertura.xml" "-targetdir:/build/report" 

if [ -f /build/test_output/failed_tests ]; then exit -1; fi 

