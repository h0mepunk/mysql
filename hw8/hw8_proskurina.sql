SELECT COUNT(*) FROM likes 
	JOIN (SELECT * FROM profiles ORDER BY birthday DESC LIMIT 10) AS young_users
		ON likes.target_id = young_users.user_id 
WHERE target_type_id = 2;

   
SELECT gender,COUNT(*) AS total FROM profiles 
  JOIN likes 
	ON profiles.user_id = likes.user_id 
GROUP BY gender 
ORDER BY total DESC;
  

SELECT first_name, last_name ,COUNT(*) AS activity FROM users 
	JOIN likes 
		ON  likes.user_id = users.id
	JOIN media  
		ON media.user_id = users.id
	JOIN messages 
		ON messages.from_user_id = users.id
GROUP BY users.id
ORDER BY activity ASC LIMIT 10;
   