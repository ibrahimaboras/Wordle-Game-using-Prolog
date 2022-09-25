build_kb:-
	write('Please enter a word and its category on separate lines:'),nl,
	read(W), 
	( W = done -> nl,write('Done building the words database...'), nl,nl;
	  read(C),
	  assert(word(W,C)),
	  build_kb
	).
	

list_of_random(C,L):-
	setof(X, C^word(X,C), L).


is_category(C):-
	word(_,C).


check_is_category(C, Result):-
	(is_category(C) -> append([C],[],Result), !;
	write('This category does not exist.'),nl,
	write('Choose a category:'),nl,
	read(Category),
	check_is_category(Category, Result)
	).

categories(L):- 
	setof(X, Y^word(Y,X), L).
	
	
available_length(L):-
		word(X,_),
		atom_chars(X,R),
		length(R, L).
		

correct_letters(L1,L2,CL):- correct_letters(L1,L2,[],CL).		

correct_letters(_,[],Acc,Acc).

correct_letters(L1,[H|T],Acc,CL):-
	\+member(H,Acc),
	(member(H,L1) -> append(Acc,[H],Acc1), 
	correct_letters(L1,T,Acc1,CL); 
	correct_letters(L1,T,Acc,CL)
	).
	
correct_letters(L1,[H|T],Acc,CL):-
	member(H,Acc),
	correct_letters(L1,T,Acc,CL).
	
	
	
correct_positions(L1,L2,CP):- correct_positions(L1,L2,[],CP).
	
correct_positions([],[],Acc,Acc).

correct_positions([H|T],[H1|T1],Acc,CP):-
	(H = H1 -> append(Acc,[H],Acc1),
	correct_positions(T,T1,Acc1,CP);
	correct_positions(T,T1,Acc,CP)
	).
	
	
pick_word(W,L,C):-
	list_of_random(C,LR),
	random_member(W,LR),
	atom_chars(W,List),
	length(List, L).
		
check_pick_word(W,L,C,R):-
	number(L), 
	(available_length(L), pick_word(W,L,C) -> R = L;
	write('There are no words of this length.'),nl,
	write('Choose a length'),nl,
	read(Length),
	check_pick_word(W,Length,C,R)
	).

check_pick_word(W,L,C,R):-
	\+number(L),
	write('Enter a number'),nl,
	write('Choose a length'),nl,
	read(Length),
	check_pick_word(W,Length,C,R).


play_helper(W,L,C,L1):-
	L1 > 1,
	write('Enter a word composed of '), write(L), write(' letters:'),nl,
	read(Pl_word),
	atom_chars(W, W1),
	atom_chars(Pl_word,R),
	length(R, Pl_word_length),
	(Pl_word = W -> write('You Won!');
	Pl_word_length \= L -> write('Word is not composed of '), write(L), write(' letters. Try again.'),nl,
	write('Remaining Guesses are '), write(L1),nl,nl,
	play_helper(W,L,C,L1);
	\+word(Pl_word,_) -> write('Enter a valid word from the database'),nl,
	write('Remaining Guesses are '), write(L1),nl,nl,
	play_helper(W,L,C,L1);
	write('Correct letters are: '), correct_letters(W1,R,CL),write(CL),nl,
	write('Correct letters in correct positions are: '), correct_positions(W1,R,CP), write(CP),nl,
	L2 is L1 - 1,
	write('Remaining Guesses are '), write(L2), nl,nl,
	play_helper(W,L,C,L2)
	).
	
play_helper(W,L,C,L1):-
	L1 = 1,
	write('Enter a word composed of '), write(L), write(' letters:'),nl,
	read(Pl_word),
	atom_chars(Pl_word,R),
	length(R, Pl_word_length),
	(Pl_word = W -> write('You Won!');
	Pl_word_length \= L -> write('Word is not composed of '), write(L), write(' letters. Try again.'),nl,
	play_helper(W,L,C,L1);
	\+word(Pl_word,_) -> write('Enter a valid word from the database'),nl,
	write('Remaining Guesses are '), write(L1),nl,nl,
	play_helper(W,L,C,L1);
	write('You Lost!'), !
	).



play:-
	write('The available categories are: '),
	categories(Available),
	write(Available),nl,
	write('Choose a category:'),nl,
	read(Category),
	check_is_category(Category, [Result|_]),
	write('Choose a length'),nl,
	read(Length),
	check_pick_word(Word,Length,Result,R),
	write('Game started. You have 6 guesses.'),nl,nl,
	play_helper(Word,R,Category,6).


main:-
	write('Welcome to Pro-Wordle!'),nl,
	write('----------------------'),nl,nl,
	build_kb,
	play.
	
