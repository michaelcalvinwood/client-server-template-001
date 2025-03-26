import React, { useState } from 'react';
import { IonButton } from '@ionic/react';

const GetFile = ({ handleSelectedFiles }) => {
  const [isDragging, setIsDragging] = useState(false);

  const handleFileChange = (event) => {
    const files = Array.from(event.target.files);
    if (files.length > 0) {
      console.log('Selected files:', files.map(file => ({
        name: file.name,
        size: file.size,
        type: file.type
      })));
      handleSelectedFiles(files);
    }
  };

  const handleDrag = (e) => {
    e.preventDefault();
    e.stopPropagation();
  };

  const handleDragIn = (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.dataTransfer.items && e.dataTransfer.items.length > 0) {
      setIsDragging(true);
    }
  };

  const handleDragOut = (e) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);

    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      const files = Array.from(e.dataTransfer.files);
      console.log('Dropped files:', files.map(file => ({
        name: file.name,
        size: file.size,
        type: file.type
      })));
      handleSelectedFiles(files);
      e.dataTransfer.clearData();
    }
  };

  return (
    <div 
      style={{ 
        padding: '20px',
        position: 'relative'
      }}
    >
      <div
        onDragEnter={handleDragIn}
        onDragLeave={handleDragOut}
        onDragOver={handleDrag}
        onDrop={handleDrop}
        style={{
          border: `2px dashed ${isDragging ? '#4a90e2' : '#ccc'}`,
          borderRadius: '8px',
          padding: '40px 20px',
          textAlign: 'center',
          backgroundColor: isDragging ? 'rgba(74, 144, 226, 0.1)' : 'transparent',
          transition: 'all 0.2s ease-in-out'
        }}
      >
        <input
          type="file"
          multiple
          onChange={handleFileChange}
          style={{ display: 'none' }}
          id="fileInput"
        />
        <IonButton 
          expand="block"
          onClick={() => document.getElementById('fileInput').click()}
        >
          Choose Files
        </IonButton>
        <p style={{ 
          margin: '10px 0 0',
          color: '#666',
          fontSize: '0.9em'
        }}>
          or drag and drop your files here
        </p>
      </div>
    </div>
  );
};

export default GetFile;
