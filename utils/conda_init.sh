#>>> conda initialize >>>
#!! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/cluster/home/klee/miniforge3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
   eval "$__conda_setup"
else
   if [ -f "/cluster/home/klee/miniforge3/etc/profile.d/conda.sh" ]; then
       . "/cluster/home/klee/miniforge3/etc/profile.d/conda.sh"
   else
       export PATH="/cluster/home/klee/miniforge3/bin:$PATH"
   fi
fi
unset __conda_setup
#<<< conda initialize <<<

. "$HOME/.cargo/env"
export PATH=/cluster/home/klee/anaconda3/envs/myenv/bin:$PATH


#>>> mamba initialize >>>
#!! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE='/cluster/home/klee/miniforge3/bin/mamba';
export MAMBA_ROOT_PREFIX='/cluster/home/klee/miniforge3';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
  eval "$__mamba_setup"
else
  alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
#<<< mamba initialize <<<
