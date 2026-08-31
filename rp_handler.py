import runpod


def handler(job):
    job_input = job["input"]  # Access the input from the request

    try:
        import importlib.util

        spec = importlib.util.spec_from_file_location(
            "worker_comfyui_handler",
            "/opt/worker-comfyui-handler.py",
        )
        if spec is not None and spec.loader is not None:
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            return module.handler(job)
    except FileNotFoundError:
        pass

    return job_input


runpod.serverless.start({"handler": handler})  # Required
