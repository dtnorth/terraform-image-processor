import { useState, useEffect } from "react";
import axios from "axios";

export default function Home() {
  const [images, setImages] = useState([]);
  const [file, setFile] = useState(null);

  useEffect(() => {
    fetchImages();
  }, []);

  const fetchImages = async () => {
    const { data } = await axios.get("http://localhost:5000/images");
    setImages(data);
  };

  const handleUpload = async () => {
    const formData = new FormData();
    formData.append("image", file);

    await axios.post("http://localhost:5000/upload", formData);
    fetchImages();
  };

  const handleDelete = async (id) => {
    await axios.delete(`http://localhost:5000/image/${id}`);
    fetchImages();
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Image Upload & Management</h1>
      <input type="file" onChange={(e) => setFile(e.target.files[0])} />
      <button onClick={handleUpload} className="bg-blue-500 text-white p-2">Upload</button>

      <div className="mt-6 grid grid-cols-3 gap-4">
        {images.map((img) => (
          <div key={img.id} className="border p-4">
            <img src={img.originalUrl} alt="Uploaded" className="w-full" />
            {img.resizedUrls.map((url) => (
              <img key={url} src={url} className="w-1/2 mt-2" alt="Resized" />
            ))}
            <button onClick={() => handleDelete(img.id)} className="bg-red-500 text-white mt-2 p-2">Delete</button>
          </div>
        ))}
      </div>
    </div>
  );
}

