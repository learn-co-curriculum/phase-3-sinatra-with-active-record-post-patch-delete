# Sinatra with Active Record: POST/PATCH/DELETE Requests

## Learning Goals

- Handle non-`GET` requests in a controller
- Access data in the request body with the params hash
- Perform CRUD actions with Active Record from the controller

## Introduction

So far, we've seen how to set up an API with Sinatra to allow frontend
applications to access data from a database in a JSON format. For many
applications, just being able to access/read data isn't enough — what kind of
app would Twitter be if you couldn't write posts? What would Instagram be if you
couldn't like photos? How embarrassing would Facebook be if you couldn't go back
and delete those regrettable high school photos?

All of those applications, and most web apps, can be broadly labeled as CRUD
applications — they allow users to Create, Read, Update, and Delete information.

We've seen a few ways to Read data in an API. We've also already seen how to
Create/Update/Delete records from a database using Active Record. All that's
left is to connect what we know from Active Record with some new techniques for
establishing routes and accessing data in our Sinatra application.

## Setup

We'll continue working on the game review application from the previous lessons.
To get set up, run:

```console
$ bundle install
$ bundle exec rake db:migrate db:seed
```

As a reminder, here's what the relationships will look like in our ERD:

![Game Reviews ERD](https://curriculum-content.s3.amazonaws.com/phase-3/active-record-associations-many-to-many/games-reviews-users-erd.png)

Then, run the server with our new Rake task:

```console
$ bundle exec rake server
```

With that set up, let's start working on some CRUD!

## Handling DELETE Requests

Let's start with the simplest action: the DELETE request. Imagine we're building
a new feature in our frontend React application. Our users want some way to
delete their reviews, in case they change their minds. In React, our component
for handling this delete action might look something like this:

```js
function ReviewItem({ review, onDeleteReview }) {
  function handleDeleteClick() {
    fetch(`http://localhost:9292/reviews/${review.id}`, {
      method: "DELETE",
    })
      .then((r) => r.json())
      .then((deletedReview) => onDeleteReview(deletedReview));
  }

  return (
    <div>
      <p>Score: {review.score}</p>
      <p>{review.comment}</p>
      <button onClick={handleDeleteClick}>Delete Review</button>
    </div>
  );
}
```

So, it looks like our server needs to handle a few new things:

- Handle requests with the `DELETE` HTTP verb to `/reviews/:id`
- Find the review to delete using the ID
- Delete the review from the database
- Send a response with the deleted review as JSON to confirm that it was deleted
  successfully, so the frontend can show the successful deletion to the user

Let's take things one step at a time. First, we'll need to handle requests by
adding a new route in the controller. We can write out a route for a DELETE
request just like we would for a GET request, just by changing the method:

```rb
class ApplicationController < Sinatra::Base
  set :default_content_type, 'application/json'

  delete '/reviews/:id' do
    # find the review using the ID
    # delete the review
    # send a response with the deleted review as JSON
  end

  # ...
end
```

Next, let's use Active Record to find and delete the review, and send back the
appropriate JSON response:

```rb
delete '/reviews/:id' do
  # find the review using the ID
  review = Review.find(params[:id])
  # delete the review
  review.destroy
  # send a response with the deleted review as JSON
  review.to_json
end
```

Great! Now, in order to test out this route, we won't be able to use the
browser, since we can only make GET requests from the browser's URL bar.
Let's use Postman instead. Try it out:

![Postman Delete Request](https://curriculum-content.s3.amazonaws.com/phase-3/sinatra-with-active-record-post-patch-delete/postman-delete.png)

This is essentially doing the same thing as this `fetch` call:

```js
fetch(`http://localhost:9292/reviews/1`, {
  method: "DELETE",
});
```

You should get a response with the deleted review as JSON, and if you check the
server logs, you should also see that Active Record ran the SQL code to delete
the record from the database:

```sql
DELETE FROM "reviews" WHERE "reviews"."id" = 1
```

## Handling POST Requests

For our next feature, let's give our users the ability to **Create** new reviews.
From the frontend, here's how our React component might look:

```js
function ReviewForm({ userId, gameId, onAddReview }) {
  const [comment, setComment] = useState("");
  const [score, setScore] = useState("0");

  function handleSubmit(e) {
    e.preventDefault();
    fetch("http://localhost:9292/reviews", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        comment: comment,
        score: score,
        user_id: userId,
        game_id: gameId,
      }),
    })
      .then((r) => r.json())
      .then((newReview) => onAddReview(newReview));
  }

  return <form onSubmit={handleSubmit}>{/* controlled form code here*/}</form>;
}
```

This request is a bit trickier than the last: in order to create a review in the
database, we need some way of getting all the data that the user entered into
the form. From the code above, you can see that we'll have access to that data
in the **body** of the request, as a JSON-formatted string. So in terms of the
steps for our server, we need to:

- Handle requests with the `POST` HTTP verb to `/reviews`
- Access the data in the body of the request
- Use that data to create a new review in the database
- Send a response with newly created review as JSON

Let's start with the easy part. We can create a new route like so:

```rb
post '/reviews' do

end
```

In this route, we'll need some way of getting access to the data in the body of
the request. Sinatra gives us access to the raw data in the request body by
calling `request.body.read`, which will return a string. We could then convert
this data from a JSON string to a Ruby hash by using
`JSON.parse(request.body.read)`. Luckily though, there's an even easier way!

This application is set up to use some additional
[Rack middleware][rack-contrib] in the `config.ru` file:

```rb
require_relative './config/environment'

# Parse JSON from the request body into the params hash
use Rack::JSONBodyParser

run ApplicationController
```

"Middleware" is a category of code that runs on every single request-response
cycle, and does some work to transform the request and make it easier to work
with once it reaches the controller. In this case, the `Rack::JSONBodyParser`
middleware does the work of reading the body of the request, parsing it from a
JSON string into a Ruby hash, and adding it to the `params` hash.

Let's see what that looks like in action. Add a breakpoint to your new route,
and require Pry at the top of the file:

```rb
require 'pry'

class ApplicationController < Sinatra::Base
  set :default_content_type, 'application/json'

  post '/reviews' do
    binding.pry
  end

  # ... rest of routes here
end
```

Then, use Postman to send a request like this:

![Postman POST request](https://curriculum-content.s3.amazonaws.com/phase-3/sinatra-with-active-record-post-patch-delete/postman-post.png)

Make sure to match these settings exactly:

- Set the HTTP verb to POST
- Set the URL to `http://localhost:9292/reviews`
- In the request **body** tab, select the "Raw" and "JSON" options from the two
  dropdown menus
- Then paste in this JSON data in the request body area:

```json
{
  "score": 10,
  "comment": "Great game.",
  "game_id": 1,
  "user_id": 1
}
```

Then, click Send to make the request. You should enter the Pry breakpoint from
your POST route, where you can interact with the request and inspect the params
hash:

```rb
params
# => {"score"=>10, "comment"=>"Great game.", "game_id"=>1, "user_id"=>1}
params[:score]
# => 10
params[:user_id]
# => 1
```

Great! As you can see, we now have access to the data from the body of the
request that we need in order to create a new `Review` instance. Exit the Pry
session with `exit`.

If we were using `fetch` instead of Postman to make this request, the params
hash would be whatever data was sent in the body of the fetch request:

```js
fetch("http://localhost:9292/reviews", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    score: 10,
    comment: "Great game.",
    game_id: 1,
    user_id: 1,
  }),
});
```

Now that we have access to that data, all that's left is to use the data with
Active Record to create a new `Review` and send a JSON response back. All
together, here's how this route should look:

```rb
post '/reviews' do
  review = Review.create(
    score: params[:score],
    comment: params[:comment],
    game_id: params[:game_id],
    user_id: params[:user_id]
  )
  review.to_json
end
```

Try running the request through Postman again. Your new review should be added
to the database and you should get back a JSON response with the review data.
Nice!

## Handling PATCH Requests

Onto the last HTTP verb: `PATCH`! Now that you've learned about `POST` and
`DELETE` requests, this should be more straightforward. From the frontend, we
might need to use a `PATCH` request to handle a feature that would allow a user
to update their review, in case they change their minds:

```js
function EditReviewForm({ review, onUpdateReview }) {
  const [comment, setComment] = useState("");
  const [score, setScore] = useState("0");

  function handleSubmit(e) {
    e.preventDefault();
    fetch(`http://localhost:9292/reviews/${review.id}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        comment: comment,
        score: score,
      }),
    })
      .then((r) => r.json())
      .then((updatedReview) => onUpdateReview(updatedReview));
  }

  return <form onSubmit={handleSubmit}>{/* controlled form code here*/}</form>;
}
```

The steps we'll need to handle on the server for this request are basically a
combination of DELETE and POST. We'll need to:

- Handle requests with the `PATCH` HTTP verb to `/reviews/:id`
- Find the review to update using the ID
- Access the data in the body of the request
- Use that data to update the review in the database
- Send a response with updated review as JSON

Give it a shot yourself before looking at the solution! You have all the tools
you need to get this request working. When you're ready, keep scrolling...

...

...

...

...

...

...

Ok, here's how the code for this route would look:

```rb
patch '/reviews/:id' do
  review = Review.find(params[:id])
  review.update(
    score: params[:score],
    comment: params[:comment]
  )
  review.to_json
end
```

And here's how you could test it out in Postman:

![Postman PATCH request](https://curriculum-content.s3.amazonaws.com/phase-3/sinatra-with-active-record-post-patch-delete/postman-patch.png)

Notice we're only updating the score and comment: it would be strange to change
which user left a review, or which game a review was left for.

## Conclusion

You're at the point now where you can create a JSON API that handles all four
CRUD actions: Create, Read, Update, and Delete. With just these four actions,
you can build just about any application you can think of!

## Resources

- [HTTP Verbs](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods)
- [Download Postman](https://www.postman.com/downloads/)

[rack-contrib]: https://github.com/rack/rack-contrib
