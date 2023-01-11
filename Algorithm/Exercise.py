# Some of the built-in functions are only valid in Python3,
# so make sure you run the code under Python3.x
########################### Task 1 ###########################
def maxPathSum(grid):
    rows = len(grid)
    cols = len(grid[0])
    
    for i in range(rows):
        for j in range(len(grid[0])):
            if i == 0 and j == 0: 
                continue
            if i == 0: 
                grid[i][j] += grid[i][j - 1]
            elif j == 0: 
                grid[i][j] += grid[i - 1][j]
            else: 
                grid[i][j] += max(grid[i][j - 1], grid[i - 1][j])
    return grid[-1][-1]

########################### Task 2 ###########################
def allPaths(g):
    paths = []
    path = []
    src = "S"
    dst = "T"
    path.append(src)

    def DFS(src, dst, g, path, paths):
        if (src == dst):
            paths.append(path.copy())
        else:
            if g.__contains__(src):
                for node in g[src]:
                    path.append(node)
                    DFS(node, dst, g, path, paths)
                    path.pop()
    DFS(src, dst, g, path, paths)
    return paths

########################### Task 3 ###########################        
def findMedian(x, y):
    k = len(x) # find k and (k+1)th element
    mid = k//2 -1
    xNow = 0
    yNow = 0
    while (xNow < len(x) and yNow < len(x) and mid >= 0):
        if (x[xNow+mid] <= y[yNow+mid]):
            xNow = xNow + mid + 1
            k = k-k//2
            mid = k//2 - 1
        else:
            yNow = yNow + mid + 1
            k = k-k//2
            mid = k//2 - 1
            
    if (x[xNow] <= y[yNow]):
        if (xNow < len(x)-1) and x[xNow+1] < y[yNow]:
            return (x[xNow]+ x[xNow+1])/2
        else:
            return (x[xNow]+ y[yNow])/2
    else:
        if (yNow < len(x)-1) and y[yNow+1] < x[xNow]:
            return (y[yNow]+y[yNow+1])/2
        else:
            return (y[yNow]+x[xNow])/2
        
########################### Task 4 ###########################
def LPP(s):
    if (len(s) < 2):
        return s
    
    s="#"+"#".join(s)+"#"
    p = [0]*(len(s))
    maxRight = 0
    center = 0
    maxLen = 1
    prefix = []
    
    for i in range(len(s)):
        if i < maxRight:
            p[i] = min(maxRight - i , p[2*center - i])
        newLeft = i - (1 + p[i])
        newRight = i + (1 + p[i])
        
        while newLeft >= 0 and newRight < len(s) and s[newLeft] == s[newRight]:
            p[i] += 1
            newLeft -= 1
            newRight += 1
        if (i + p[i]) > maxRight:
            maxRight = i + p[i]
            center = i
        if (p[i] > maxLen):
            maxLen = p[i]
    for i in range(len(p)):
        p[i] = p[i]-i
        if p[i] == 0:
            prefix.append(i)
    maxCenter = max(prefix)
    
    return s[:2*maxCenter].replace("#","")





