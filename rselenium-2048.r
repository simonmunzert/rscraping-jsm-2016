### SECTION I: fire up the game ####
 
require(RSelenium)
 
checkForServer()
startServer()
 
remDr <- remoteDriver(remoteServerAddr = "localhost" 
                      , port = 4444
                      , browserName = "firefox"
)
Sys.sleep(1)
 
remDr$open()
 
# navigate to page
remDr$navigate("http://gabrielecirulli.github.io/2048/")
 
 
#### SECTION II: functions for predicting board states ####
# functions to determine current board state:
pos.strip = function(string){
 
  first.cut = strsplit(string,split = " tile-position-")[[1]]
  val.sub = as.numeric(strsplit(first.cut[1],split = "-")[[1]][2])
  pos.sub = first.cut[2]
  second.cut = strsplit(pos.sub,split = " ")[[1]][1]
  third.cut = strsplit(second.cut, split = "-")[[1]]
  conv.to.num = as.numeric(third.cut)
  rev.order = rev(conv.to.num)
  out = c(rev.order,val.sub)
  return(out)
}
 
conv.to.frame = function(htmlParsedPage){
 
n1 = xpathSApply(htmlParsedPage,"//div[@class='tile-container']",xmlValue)
n2 = xpathSApply(htmlParsedPage,"//div[@class='tile-container']//@class")
n2 = n2[-1]
curr.len = length(n2)
n2 = n2[which((1:curr.len %% 2) == 1)]
 
mat = t(sapply(n2,pos.strip))
 
rownames(mat) = 1:nrow(mat)
colnames(mat) = c("x","y","val")
mat = data.frame(mat)
 
empty.frame = matrix(rep(NA,16),nrow = 4)
 
for(i in 1:nrow(mat)){
  empty.frame[mat$x[i],mat$y[i]] = mat$val[i]
}
 
return(empty.frame)
}
 
## predicting next board state:
comb.func = function(vec){
  empty.vec = rep(NA,4)
  four.three = as.numeric(sum(vec[4] == vec[3],na.rm = TRUE))
  three.two = as.numeric(sum(vec[3] == vec[2],na.rm = TRUE))
  two.one = as.numeric(sum(vec[2] == vec[1],na.rm = TRUE))
  layout.vec = c(two.one,three.two,four.three)
 
  if(all(layout.vec == c(1,1,1))){
    empty.vec[3] = 2*vec[2]
    empty.vec[4] = 2*vec[4]
  }
 
  if(all(layout.vec == c(0,0,1))){
    empty.vec[4] = 2*vec[4]
    empty.vec[1:3] = c(NA,vec[1:2])
  }
 
 
  if(all(layout.vec == c(0,1,0))){
    empty.vec[3] = 2*vec[3]
    empty.vec[2] = vec[1]
    empty.vec[4] = vec[4]
  }
  if(all(layout.vec == c(1,0,0))){
    empty.vec[2] = 2*vec[2]
    empty.vec[3:4] = vec[3:4]
  }
 
  if(all(layout.vec == c(0,1,1))){
    empty.vec[4] = 2*vec[4]
    empty.vec[1:3] = c(NA,vec[1:2])
  }
 
  if(all(layout.vec == c(1,0,1))){
    empty.vec[3] = 2*vec[2]
    empty.vec[4] = 2*vec[4]
  }
  if(all(layout.vec == c(1,1,0))){
    empty.vec[3] = 2*vec[3]
    empty.vec[2] = vec[1]
    empty.vec[4] = vec[4]
  }
  if(all(layout.vec == c(0,0,0))){
    empty.vec = vec
  }
  return(empty.vec)
}
 
collect.right = function(board){
  first.move = t(apply(board,1,function(x){
  n.na = sum(is.na(x))
  stripped = x[!is.na(x)]
  comb = c(rep(NA,n.na),stripped)
  return(comb)
  }))
  second.move = t(apply(first.move,1,comb.func))
  return(second.move)
}
 
ninety.rot = function(mat){
  empty = matrix(rep(NA,16),nrow = 4)
  empty[1,] = mat[,4]
  empty[2,] = mat[,3]
  empty[3,] = mat[,2]
  empty[4,] = mat[,1]
  return(empty)
}
 
collect.down = function(board){
  temp.turn = ninety.rot(board)
  collapse = collect.right(temp.turn)
  turn.back = ninety.rot(ninety.rot(ninety.rot(collapse)))
  return(turn.back)
}
 
collect.up = function(board){
  temp.turn = ninety.rot(ninety.rot(ninety.rot(board)))
  collapse = collect.right(temp.turn)
  turn.back = ninety.rot(collapse)
  return(turn.back)
}
 
collect.left = function(board){
  temp.turn = ninety.rot(ninety.rot(board))
  collapse = collect.right(temp.turn)
  turn.back = ninety.rot(ninety.rot(collapse))
  return(turn.back)
}
 
count.tiles = function(board){
  sum(!is.na(board))
}
 
preds.lst = function(Parsed){ 
  board.temp = conv.to.frame(Parsed)
  preds = list(orig = board.temp,
               left = collect.left(board.temp),
               right = collect.right(board.temp),
               up = collect.up(board.temp),
               down = collect.down(board.temp))
  return(preds)
}
 
allowed.func = function(lst){
  # note: this is a function of the output from preds.lst
  # returns the directions that are currently allowed.
  vals = unlist(lapply(lst[2:5],function(x){identical(x,lst[[1]])}))
  sub = names(vals)[which(vals == F)]
  return(sub)
}
 
legal.sub = function(Parsed){
  preds = preds.lst(Parsed)
  moves = allowed.func(preds)
  out = preds[names(preds) %in% moves]
  return(out)
}
 
prep.to.send = function(choice.arrow){
  return(paste(choice.arrow,"_arrow",sep = ""))
}
 
send.func = function(prepped.choice){
  remDr$sendKeysToActiveElement(list(key = prepped.choice))
}
 
comb.move = function(arrow){
  return(send.func(prep.to.send(arrow)))
}
 
 
#### Section III: functions to determine properties of boards ####
 
tiles.in.fourth = function(board){
  sum(!is.na(board[,4]))
}
 
tot.sum.in.fourth = function(board){
  sum(board[,4],na.rm = TRUE)
}
 
 
bottom.right.val = function(board){
  return(sum(board[4,4],na.rm = TRUE))
}
 
bottom.right.third.val = function(board){
  return(sum(board[3,4],na.rm = TRUE))
}
 
bottom.right.sec.val = function(board){
  return(sum(board[2,4],na.rm = TRUE))
}
 
bottom.right.first.val = function(board){
  return(sum(board[1,4],na.rm = TRUE))
}
 
prep.for.next = function(board){
  sum(board[,3] == board[,4],na.rm = TRUE)
}
 
prep.for.next.third = function(board){
  sum(board[,2] == board[,3],na.rm = TRUE)
}
 
prep.for.next.second = function(board){
  sum(board[,1] == board[,2],na.rm = TRUE)
}
 
 
#### SECTION IV: scoring boards ####
top.val.moves = function(score.vec){
  raw.scores = score.vec
  temp.max = max(raw.scores)
  indx = which(raw.scores == temp.max)
  maxima = names(raw.scores)[indx]
  return(maxima)  
}
 
score.em = function(legal.board, FUN){
  return(unlist(lapply(legal.board,FUN)))  
}
 
 
 
#### SECTION V: algorithm for a single play ####
 
play.func = function(parsed){
  legal.boards = legal.sub(parsed)
 
  bottom.right = score.em(legal.boards, bottom.right.val)
  leftover.moves = top.val.moves(bottom.right)
  leftover.boards = legal.boards[leftover.moves]
  if(length(leftover.boards) == 1){
    return(comb.move(names(leftover.boards)))}
 
  bottom.right.third = score.em(leftover.boards, bottom.right.third.val)
  leftover.moves = top.val.moves(bottom.right.third)
  leftover.boards = legal.boards[leftover.moves]
  if(length(leftover.boards) == 1){
    return(comb.move(names(leftover.boards)))}
 
  bottom.right.sec = score.em(leftover.boards, bottom.right.sec.val)
  leftover.moves = top.val.moves(bottom.right.sec)
  leftover.boards = legal.boards[leftover.moves]
  if(length(leftover.boards) == 1){
    return(comb.move(names(leftover.boards)))}  
 
  tot.fourth.scores = score.em(leftover.boards, tot.sum.in.fourth)
  leftover.moves = top.val.moves(tot.fourth.scores)
  leftover.boards = legal.boards[leftover.moves]
  if(length(leftover.boards) == 1){
    return(comb.move(names(leftover.boards)))}
 
  prep.scores = score.em(leftover.boards, prep.for.next)
  leftover.moves = top.val.moves(prep.scores)
  leftover.boards = legal.boards[leftover.moves]
  if(length(leftover.boards) == 1){
    return(comb.move(names(leftover.boards)))}
 
  tile.tots = score.em(leftover.boards, function(x){20 - count.tiles(x)})
  leftover.moves = top.val.moves(tile.tots)
  leftover.boards = legal.boards[leftover.moves]
  if(length(leftover.boards) == 1){
    return(comb.move(names(leftover.boards)))}
 
  prep.scores.third = score.em(leftover.boards, prep.for.next.third)
  leftover.moves = top.val.moves(prep.scores.third)
  leftover.boards = legal.boards[leftover.moves]
  if(length(leftover.boards) == 1){
    return(comb.move(names(leftover.boards)))}
 
  prep.scores.second = score.em(leftover.boards, prep.for.next.second)
  leftover.moves = top.val.moves(prep.scores.second)
  leftover.boards = legal.boards[leftover.moves]
  if(length(leftover.boards) == 1){
    return(comb.move(names(leftover.boards)))}
 
  rand.choice = leftover.moves[sample(1:length(leftover.boards),1)]
  return(comb.move(rand.choice))
}
 
 
execute = function(){
  temp = htmlParse(remDr$getPageSource()[[1]])
  play.func(temp)
}
 
 
 
 
#### SECTION VI Playing the game ####
 
grand.play = function(){
remDr$navigate("http://gabrielecirulli.github.io/2048/")
temp2 = rep("Continue",2)
while(temp2[2] != "Game over!"){
  temp = htmlParse(remDr$getPageSource()[[1]])
  execute()
  temp2 = xpathSApply(temp,"//p",xmlValue)
  curr.score = as.numeric(strsplit(xpathSApply(temp,"//div[@class='score-container']",xmlValue),split = "\\+")[[1]][1])
}
return(curr.score)
}
 
# example:
