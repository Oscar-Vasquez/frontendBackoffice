import { z } from 'zod';
import { toast } from 'react-hot-toast';
import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { UsersService } from '@/services/users.service';

const formSchema = z.object({
  // Add your schema here
});

const NewUserForm = () => {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);

  const onSubmit = async (values: z.infer<typeof formSchema>) => {
    try {
      setIsLoading(true);
      await UsersService.createUser(values);
      toast({
        title: "Usuario creado",
        description: "El usuario ha sido creado exitosamente",
      });
      router.push('/dashboard/users');
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Error al crear el usuario';
      alert(errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div>
      {/* Render your form here */}
    </div>
  );
};

export default NewUserForm; 