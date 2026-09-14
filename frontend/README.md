## **Book Review App - Frontend**  
This is the **frontend** of the **Book Review App**, built with **Next.js and Tailwind CSS**. It provides an interactive interface for users to:  
- Browse books and reviews  
- Register and log in  
- Submit reviews (if logged in)  

The frontend is **separated** from the backend, allowing independent deployment.  

---

## **Prerequisites**  
Before setting up the frontend, ensure you have the following installed:  

- **Node.js (v18 or later)**  
  Download & install: [Node.js Official Website](https://nodejs.org/)  
  Verify installation:  
  ```sh
  node -v
  ```

- **Backend API Running**  
  Ensure the backend is running on `http://localhost:3001`.  
  If not, follow the **backend README** to set it up.  

---

## **Step 1: Clone the Repository**  
```sh
git clone https://github.com/pravinmishraaws/book-review-app.git
cd book-review-app/frontend
```

---

## **Step 2: Install Dependencies**  
Run the following command:  
```sh
npm install
```
This installs:
- **Next.js** (React framework)
- **Axios** (For API calls)
- **Tailwind CSS** (For styling)
- **React Context API** (For global state management)

---

## **Step 3: Configure Environment Variables**  
Create a `.env.local` file in the `frontend/` directory:  
```sh
touch .env
```
Open `.env.local` and set the backend API URL:  
```env
NEXT_PUBLIC_API_URL=http://localhost:3001
```
This ensures API requests point to the correct backend.

---

## **Step 4: Start the Frontend**  
Run the following command:  
```sh
npm run dev
```
If everything is set up correctly, you should see:  
```
Local: http://localhost:3000
```
Open your browser and go to `http://localhost:3000`.

---

## **Step 5: Folder Structure**  
```
/frontend
 ├── /src
 │   ├── /app
 │   │   ├── page.js       # Home page (list of books)
 │   │   ├── /book/[id]    # Dynamic route for book details
 │   │   ├── /login        # Login page
 │   │   ├── /register     # Register page
 │   ├── /components       # Reusable UI components (Navbar)
 │   ├── /context          # React Context for user authentication
 │   ├── /services         # API service functions (Axios)
 │   ├── /styles           # Global styles (Tailwind)
 ├── next.config.js        # Next.js configuration
 ├── package.json          # Frontend dependencies
 ├── .env.local            # Environment variables
 ├── README.md             # Frontend documentation
```

---

## **Step 6: Testing the UI & API Integration**  

### **1. View List of Books**  
Go to **`http://localhost:3000/`**  
- The homepage should display books fetched from **`/api/books`**.  

---

### **2. User Registration**  
Go to **`http://localhost:3000/register`**  
- Enter name, email, and password.  
- On successful registration, it should redirect to the login page.  

---

### **3. User Login**  
Go to **`http://localhost:3000/login`**  
- Enter registered email & password.  
- On successful login:  
  - The **navbar should display the user’s full name**.  
  - The **Logout button should be visible**.  
  - The **JWT token should be stored in local storage**.

---

### **4. View Book Details & Reviews**  
Click on a book from the homepage to open **`/book/[id]`**  
- The page should display **book details** and **user reviews** fetched from `/api/reviews/:bookId`.

---

### **5. Submit a Review**  
If logged in, submit a review.  
- The review should be **added instantly** without refreshing the page.  
- The new review should include the **username** and **timestamp**.  

---

### **Step 7: Deployment**  
To deploy the frontend, use **Vercel** or **Netlify**.  

### **Deploy with Vercel**  
1. Install Vercel CLI  
   ```sh
   npm install -g vercel
   ```
2. Deploy  
   ```sh
   vercel
   ```
3. Follow instructions to set environment variables for production.  

---

## **Troubleshooting**  

### **Issue: API Calls Fail**  
- Ensure the backend is **running on `http://localhost:3001`**.  
- Check if **CORS** is enabled in the backend (`server.js`).  

### **Issue: Login Not Working**  
- Open browser DevTools (**F12 → Application → Local Storage**)  
- Check if the **JWT token is stored** after login.  
- Ensure the `.env.local` file contains the correct API URL.  

### **Issue: Frontend Not Updating After Login**  
- Ensure `UserContext` is correctly managing the authentication state.  
- Try **clearing local storage** and logging in again.  

```sh
localStorage.clear()
```

---

## **Next Steps: If you are developer and want to continue then**
- Add **pagination & sorting** for books and reviews.  
- Implement **admin features** (book creation, user management).  
- Improve UI with **loading indicators** and **error handling**.  




This Deployment is done by Venkatesh Gangavarapu
