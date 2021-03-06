with c_user as (select movie_id,rating from user_movie
                where user_id=?),--ratings [-5,5]

   ranks as (select um.user_id,x.movie_id,(10 - ABS(x.rating-um.rating)) as rank
				   from c_user x, user_movie um where um.movie_id in
				   (select movie_id from c_user)),

   bonds as (select user_id, sum(rank) as bond 
				   from ranks
				   group by user_id),

   r_pool as (select movie_id, rating*bond as rating007
					from user_movie natural join bonds
					where movie_id not in
					(select movie_id from c_user)),
			  
	d_pool as (select movie_id,avg(rating007) as final_score--Note the "avg"
					from r_pool group by movie_id)
	
	select title,final_score 
	from d_pool natural join movie 
  order by final_score desc