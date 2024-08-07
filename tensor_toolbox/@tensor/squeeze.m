function Y = squeeze(X)
%SQUEEZE Remove singleton dimensions from a tensor.
%
%   Y = SQUEEZE(X) returns a tensor Y with the same elements as
%   X but with all the singleton dimensions removed.  A singleton
%   is a dimension such that size(X,dim)==1.
%
%   If X has *only* singleton dimensions, then Y is a scalar.
%
%   Examples
%   squeeze( tenrand([2,1,3]) ) %<-- returns a 2-by-3 tensor
%   squeeze( tenrand([1 1]) ) %<-- returns a scalar
%
%   See also TENSOR, TENSOR/RESHAPE, TENSOR/PERMUTE.
%
%Tensor Toolbox for MATLAB: <a href="https://www.tensortoolbox.org">www.tensortoolbox.org</a>


if all(X.size > 1)
    % No singleton dimensions to squeeze
    Y = X;
else
    idx = find(X.size > 1);
    if numel(idx) == 0
        % Scalar case - only singleton dimensions
        Y = X.data;
    else
        siz = X.size(idx);
        Y = tensor(squeeze(X.data), siz);
    end
end

return;
