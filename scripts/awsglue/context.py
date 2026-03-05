# stub for awsglue.context

class GlueContext:
    def __init__(self, spark_context):
        self.spark_session = None

    def create_dynamic_frame(self, *args, **kwargs):
        class DummyDF:
            pass
        return DummyDF()

    def write_dynamic_frame(self, *args, **kwargs):
        pass
