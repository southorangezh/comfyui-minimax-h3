import importlib.util

import runpod

# rgthree Fast Groups Bypasser/Muter are browser virtual nodes. They never
# register in ComfyUI's Python NODE_CLASS_MAPPINGS, so /prompt returns
# missing_node_type if they remain in an API workflow.
FRONTEND_ONLY_CLASS_TYPES = {
    "Fast Groups Bypasser (rgthree)",
    "Fast Groups Muter (rgthree)",
    "Fast Muter (rgthree)",
    "Fast Bypasser (rgthree)",
}


def _is_api_prompt(graph):
    if not isinstance(graph, dict) or not graph:
        return False
    first = next(iter(graph.values()))
    return isinstance(first, dict) and "class_type" in first


def strip_frontend_only_nodes(graph):
    if not _is_api_prompt(graph):
        return graph
    stripped = {
        node_id: node
        for node_id, node in graph.items()
        if not (
            isinstance(node, dict)
            and node.get("class_type") in FRONTEND_ONLY_CLASS_TYPES
        )
    }
    removed = set(graph) - set(stripped)
    if removed:
        print(f"worker-comfyui: dropped frontend-only nodes {sorted(removed)}")
    return stripped


def handler(job):
    job_input = job.get("input") or {}
    if isinstance(job_input, dict):
        if _is_api_prompt(job_input.get("workflow")):
            job_input["workflow"] = strip_frontend_only_nodes(job_input["workflow"])
        elif _is_api_prompt(job_input):
            job["input"] = strip_frontend_only_nodes(job_input)

    try:
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

    return job.get("input")


runpod.serverless.start({"handler": handler})
