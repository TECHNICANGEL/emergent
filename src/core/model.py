import os
import sys
import logging
from typing import List, Optional, Union, Dict, Any

# Ensure DLLs are loaded correctly on Windows
def _setup_dlls():
    if sys.platform == "win32":
        cuda_bin = r"C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.1\bin"
        cuda_bin_x64 = r"C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.1\bin\x64"
        
        # We need to find where llama_cpp is installed to get its lib folder
        try:
            import llama_cpp
            lib_dir = os.path.join(os.path.dirname(llama_cpp.__file__), "lib")
        except ImportError:
            lib_dir = None

        for d in [cuda_bin, cuda_bin_x64, lib_dir]:
            if d and os.path.exists(d):
                if hasattr(os, 'add_dll_directory'):
                    try:
                        os.add_dll_directory(d)
                    except Exception as e:
                        logging.warning(f"Failed to add DLL directory {d}: {e}")
                else:
                    os.environ["PATH"] = d + os.path.pathsep + os.environ["PATH"]

_setup_dlls()
import llama_cpp
from llama_cpp import Llama

class ModelWrapper:
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.model_path = config.get("path")
        self.n_gpu_layers = config.get("n_gpu_layers", -1)
        self.n_ctx = config.get("n_ctx", 4096)
        self.temperature = config.get("temperature", 0.85)
        self.seed = config.get("seed", -1)
        
        if not self.model_path or not os.path.exists(self.model_path):
            logging.error(f"Model path not found: {self.model_path}")
            raise FileNotFoundError(f"Model path not found: {self.model_path}")

        logging.info(f"Loading model from {self.model_path} with {self.n_gpu_layers} GPU layers...")
        
        self.llm = Llama(
            model_path=self.model_path,
            n_gpu_layers=self.n_gpu_layers,
            n_ctx=self.n_ctx,
            seed=self.seed,
            verbose=True
        )
        
        # Check if CUDA is actually being used
        # In 0.3.x, we can check if ggml-cuda was loaded
        self.using_cuda = getattr(llama_cpp, 'GGML_USE_CUDA', False)
        if self.using_cuda:
            logging.info("Model loaded successfully with CUDA support.")
        else:
            logging.warning("Model loaded, but CUDA support was not detected. Falling back to CPU.")

    def generate(self, prompt: str, max_tokens: int = 256, stop: Optional[List[str]] = None) -> str:
        output = self.llm(
            prompt,
            max_tokens=max_tokens,
            stop=stop or self.config.get("stop", ["\n\n"]),
            temperature=self.temperature,
            top_p=self.config.get("top_p", 0.95),
            top_k=self.config.get("top_k", 40),
            repeat_penalty=self.config.get("repeat_penalty", 1.1)
        )
        return output["choices"][0]["text"]

    def get_info(self) -> Dict[str, Any]:
        return {
            "model_path": self.model_path,
            "using_cuda": self.using_cuda,
            "n_ctx": self.n_ctx,
            "n_gpu_layers": self.n_gpu_layers
        }
