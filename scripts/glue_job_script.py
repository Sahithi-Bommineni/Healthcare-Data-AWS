import sys 
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.job import Job
from awsglue.context import GlueContext
from pyspark.sql import SparkSession

#initializing glue
glue_context = GlueContext(SparkContext.getOrCreate())
spark = glue_context.spark_session
job = Job(glue_context)

#reading data from raw folder
datasource = glue_context.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={"paths": ["s3://cms-healthcare-data-bucket-2026/raw_data/"]},
    format="json"
)

#transforming data
cleaned_data = DropNullFields.apply(frame=datasource)

#save as parquet in silver folder
glue_context.write_dynamic_frame.from_options(
    frame=cleaned_data,
    connection_type="s3",
    connection_options={"path": "s3://cms-healthcare-data-bucket-2026/silver_data/"},
    format="parquet"
)

job.commit()